package cn.x1ongzhu.tencentBgLocation;

import android.content.Intent;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaArgs;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * Created by xiongzhu on 2017/11/23.
 */

public class tencentBgLocation extends CordovaPlugin {
    private Intent locationService;

    @Override
    public boolean execute(String action, CordovaArgs args, final CallbackContext callbackContext) throws JSONException {
        if (action.equals("start")) {
            locationService = new Intent(webView.getContext(), LocationService.class);
            JSONObject params = args.getJSONObject(0);
            locationService.putExtra("url", params.getString("url"));
            locationService.putExtra("carplate", params.getString("carplate"));
            locationService.putExtra("handoverno", params.getString("handoverno"));
            webView.getContext().startService(locationService);
            callbackContext.success();
        } else if (action.equals("stop")) {
            if (locationService != null) {
                webView.getContext().stopService(locationService);
            }
            callbackContext.success();
        }
        return super.execute(action, args, callbackContext);
    }
}
