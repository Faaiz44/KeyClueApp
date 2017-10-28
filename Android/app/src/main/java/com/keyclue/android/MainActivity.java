package com.keyclue.android;

import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.net.Uri;
import android.support.annotation.NonNull;
import android.support.annotation.VisibleForTesting;
import android.support.design.widget.BottomNavigationView;
import android.support.design.widget.Snackbar;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.view.WindowManager;
import android.webkit.WebSettings;
import android.webkit.WebViewClient;
import android.widget.TextView;
import android.widget.Toast;

import com.example.hp.keyclue.R;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.analytics.FirebaseAnalytics;
import com.google.firebase.crash.FirebaseCrash;
import com.google.firebase.dynamiclinks.DynamicLink;
import com.google.firebase.dynamiclinks.FirebaseDynamicLinks;
import com.google.firebase.dynamiclinks.PendingDynamicLinkData;
import com.google.firebase.perf.FirebasePerformance;
import com.google.firebase.perf.metrics.Trace;
import com.google.firebase.remoteconfig.FirebaseRemoteConfig;
import com.google.firebase.remoteconfig.FirebaseRemoteConfigSettings;

public class MainActivity extends AppCompatActivity {

    android.webkit.WebView wv;
    // When back pressed go back
    /**
     * The {@code FirebaseAnalytics} used to record screen views.
     */
    // [START declare_analytics]
    private FirebaseAnalytics mFirebaseAnalytics;
    private static final String TAG = "MainActivity";
    private Trace mTrace;
    private String STARTUP_TRACE_NAME = "Page loading trace";
    private String REQUESTS_COUNTER_NAME = "requests sent";
    private static final String DEEP_LINK_URL = "http://keyclue.co.kr";
    private FirebaseRemoteConfig mFirebaseRemoteConfig;
    long cacheExpiration = 3600; // 1 hour in seconds.
    private String appPrimaryColor;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        mFirebaseRemoteConfig = FirebaseRemoteConfig.getInstance();
        FirebaseRemoteConfigSettings remoteConfigSettings = new FirebaseRemoteConfigSettings.Builder()
                .setDeveloperModeEnabled(true)
                .build();
        mFirebaseRemoteConfig.setConfigSettings(remoteConfigSettings);
        mFirebaseRemoteConfig.setDefaults(R.color.white);
//        // Create a deep link and display it in the UI
        final Uri deepLink1 = buildDeepLink(Uri.parse(DEEP_LINK_URL), 0);

        // [START get_deep_link]
        FirebaseDynamicLinks.getInstance()
                .getDynamicLink(getIntent())
                .addOnSuccessListener(this, new OnSuccessListener<PendingDynamicLinkData>() {
                    @Override
                    public void onSuccess(PendingDynamicLinkData pendingDynamicLinkData) {
                        // Get deep link from result (may be null if no link is found)
                        Uri deepLink = deepLink1;
                        if (pendingDynamicLinkData != null) {
                            deepLink = pendingDynamicLinkData.getLink();
                        }


                        // Handle the deep link. For example, open the linked
                        // content, or apply promotional credit to the user's
                        // account.
                        // ...

                        // [START_EXCLUDE]
                        // Display deep link in the UI
                        if (deepLink != null) {
//                            Snackbar.make(findViewById(android.R.id.content),
//                                    "Found deep link!", Snackbar.LENGTH_LONG).show();

//                            ((TextView) findViewById(R.id.link_view_receive))
//                                    .setText(deepLink.toString());
                        } else {
                            Log.d(TAG, "getDynamicLink: no link found");
                        }
                        // [END_EXCLUDE]
                    }
                })
                .addOnFailureListener(this, new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        Log.w(TAG, "getDynamicLink:onFailure", e);
                    }
                });
        // [END get_deep_link]


        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        try {
            // Begin tracing app startup tasks.
            mTrace = FirebasePerformance.getInstance().newTrace(STARTUP_TRACE_NAME);
            mFirebaseAnalytics = FirebaseAnalytics.getInstance(this);

            wv = (android.webkit.WebView) findViewById(R.id.webview);
            //Enable JavaScript
            wv.getSettings().setJavaScriptEnabled(true);
            wv.setFocusable(true);
            wv.setFocusableInTouchMode(true);
            //Set Render Priority to High
            wv.getSettings().setRenderPriority(WebSettings.RenderPriority.HIGH);
            wv.getSettings().setCacheMode(WebSettings.LOAD_NO_CACHE);
            wv.getSettings().setDomStorageEnabled(true);
            wv.getSettings().setDatabaseEnabled(true);
            wv.getSettings().setAppCacheEnabled(true);
            wv.setScrollBarStyle(View.SCROLLBARS_INSIDE_OVERLAY);
            //Load URL
            wv.loadUrl("http://keyclue.co.kr");
            wv.setWebViewClient(new WebViewClient());
            // Increment the counter of number of requests sent in the trace.
            Log.d(TAG, "Incrementing number of requests counter in trace");
            mFirebaseAnalytics.setCurrentScreen(this, "Key Clue Main", null /* class override */);
            mFirebaseAnalytics.setUserProperty("favorite_food", "Key Clue Main Page");
        }
        catch(Exception ex){
            FirebaseCrash.logcat(Log.ERROR, TAG, "NPE caught");
            FirebaseCrash.report(ex);
        }
        final BottomNavigationView bottomNavigationView = (BottomNavigationView)
                findViewById(R.id.bottom_navigation);


        mFirebaseRemoteConfig.fetch(cacheExpiration)
                .addOnCompleteListener(this, new OnCompleteListener<Void>() {
                    @Override
                    public void onComplete(@NonNull Task<Void> task) {
                        if (task.isSuccessful()) {
//                            Toast.makeText(MainActivity.this, "Fetch Succeeded",
//                                    Toast.LENGTH_SHORT).show();
                            // After config data is successfully fetched, it must be activated before newly fetched
                            // values are returned.
                            mFirebaseRemoteConfig.activateFetched();
                            appPrimaryColor = mFirebaseRemoteConfig.getString("appPrimaryColor");
                            // use remote value if promo is on, otherwise, use the default config value.
                            int color = Color.parseColor(mFirebaseRemoteConfig.getString("appPrimaryColor"));
                            bottomNavigationView.setBackgroundColor(color);
                        } else {
//                            Toast.makeText(MainActivity.this, "Fetch Failed",
//                                    Toast.LENGTH_SHORT).show();
                        }
                    }
                });
        // [END fetch_config_with_callback]

        BottomNavigationViewHelper helper = new BottomNavigationViewHelper();
        helper.disableShiftMode(bottomNavigationView);

        bottomNavigationView.setOnNavigationItemSelectedListener(
                new BottomNavigationView.OnNavigationItemSelectedListener() {
                    @Override
                    public boolean onNavigationItemSelected(@NonNull MenuItem item) {
                        switch (item.getItemId()) {
                            case R.id.action_account:
                                try {
                                    wv.loadUrl("http://keyclue.co.kr/myshop/index.html");
                                }
                                catch(Exception ex){
                                    FirebaseCrash.logcat(Log.ERROR, TAG, "General Exception caught");
                                    FirebaseCrash.report(ex);
                                }
                                Bundle params = new Bundle();
                                params.putString("Name", "Account");
                                params.putString("Description", "Account Button Tapped");
                                mFirebaseAnalytics.logEvent("AccountTapped", params);
                                break;
                            case R.id.action_backfilled:
                                Bundle backparams = new Bundle();
                                backparams.putString("Name", "Back");
                                backparams.putString("Description", "Forward Button Tapped");
                                mFirebaseAnalytics.logEvent("BackTapped", backparams);
                                try {
                                    onBackPressed();
                                }
                                catch(Exception ex){
                                    FirebaseCrash.logcat(Log.ERROR, TAG, "General Exception caught");
                                    FirebaseCrash.report(ex);
                                }
                                break;
                            case R.id.action_forwardfilled:
                                Bundle forwardparams = new Bundle();
                                forwardparams.putString("Name", "Forward");
                                forwardparams.putString("Description", "Forward Button Tapped");
                                mFirebaseAnalytics.logEvent("ForwardTapped", forwardparams);
                                try {
                                    onForwardPressed();
                                }
                                catch(Exception ex){
                                FirebaseCrash.logcat(Log.ERROR, TAG, "General Exception caught");
                                FirebaseCrash.report(ex);
                            }
                                break;
                            case R.id.action_shoppingcart:
                                Bundle shcartparams = new Bundle();
                                shcartparams.putString("Name", "Cart");
                                shcartparams.putString("Description", "Cart Button Tapped");
                                mFirebaseAnalytics.logEvent("CartTapped", shcartparams);
                                try {
                                    wv.loadUrl("http://keyclue.co.kr/order/basket.html");
                                }
                                catch(Exception ex){
                                FirebaseCrash.logcat(Log.ERROR, TAG, "General Exception caught");
                                FirebaseCrash.report(ex);
                            }
                                break;
                        }
                        return false;
                    }
                });
        Log.d(TAG, "Stopping trace");
        mTrace.stop();
    }

    @VisibleForTesting
    public Uri buildDeepLink(@NonNull Uri deepLink, int minVersion) {
        String domain = "https://ce2vx.app.goo.gl/";

        // Set dynamic link parameters:
        //  * Domain (required)
        //  * Android Parameters (required)
        //  * Deep link
        // [START build_dynamic_link]
        DynamicLink.Builder builder = FirebaseDynamicLinks.getInstance()
                .createDynamicLink()
                .setDynamicLinkDomain(domain)
                .setAndroidParameters(new DynamicLink.AndroidParameters.Builder()
                        .setMinimumVersion(minVersion)
                        .build())
                .setLink(deepLink);

        // Build the dynamic link
        DynamicLink link = builder.buildDynamicLink();
        // [END build_dynamic_link]

        // Return the dynamic link as a URI
        return link.getUri();
    }


    public void onBackPressed(){
        if (wv.canGoBack()) {
            wv.goBack();
        }else {
            super.onBackPressed();
        }
    }

    public void onForwardPressed(){
        if(wv.canGoForward()) {
            wv.goForward();
        }else{
            super.finish();
        }
    }
}
