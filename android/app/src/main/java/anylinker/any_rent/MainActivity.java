package anylinker.any_rent;

import android.widget.Toast;

import androidx.annotation.NonNull;
import android.content.Intent;

import java.net.URISyntaxException;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private String TOAST_CHANNEL = "anylinker.any_rent/login";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), TOAST_CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("pass_login")) {
                        String url = call.argument("url");
//                        System.out.println("===============================URL");
//                        System.out.println(url);
                        try {
                            Intent intent = Intent.parseUri(url, Intent.URI_INTENT_SCHEME);
//                            System.out.println("===============================intent");
//                            System.out.println(intent);
//                            System.out.println("===============================intent.getDataString()");
//                            System.out.println(intent.getDataString());
                            result.success(intent.getDataString());
                        } catch (URISyntaxException e) {
                            e.printStackTrace();
                        }
//                        Toast.makeText(this, call.argument("url"), Toast.LENGTH_SHORT).show();
                    }
                    if (call.method.equals("getMarketUrl")) {
                        String url = call.argument("url");
//                        System.out.println("===============================URL");
//                        System.out.println(url);
                        try {
                            Intent intent = Intent.parseUri(url, Intent.URI_INTENT_SCHEME);
                            String scheme = intent.getScheme();
                            String packageName = intent.getPackage();
                            if (packageName != null) {
                                result.success("market://details?id=" + packageName);
                            }
                            result.success(intent.getDataString());
                        } catch (URISyntaxException e) {
                            e.printStackTrace();
                        }
                    }
                });
    }
}