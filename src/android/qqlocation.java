package cn.x1ongzhu.qqlocation;

import android.os.Looper;
import android.support.annotation.NonNull;

import com.tencent.map.geolocation.TencentLocation;
import com.tencent.map.geolocation.TencentLocationListener;
import com.tencent.map.geolocation.TencentLocationManager;
import com.yanzhenjie.permission.AndPermission;
import com.yanzhenjie.permission.Permission;
import com.yanzhenjie.permission.PermissionListener;
import com.yanzhenjie.permission.Rationale;
import com.yanzhenjie.permission.RationaleListener;

import org.apache.cordova.CordovaPlugin;

import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.List;

/**
 * This class echoes a string called from JavaScript.
 */
public class qqlocation extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {
        if (action.equals("getLocation")) {
            AndPermission.with(cordova.getActivity())
                    .requestCode(102)
                    .permission(Permission.LOCATION)
                    .rationale(new RationaleListener() {
                        @Override
                        public void showRequestPermissionRationale(int requestCode, Rationale rationale) {
                            AndPermission.rationaleDialog(cordova.getActivity(), rationale).show();
                        }
                    })
                    .callback(new PermissionListener() {
                        @Override
                        public void onSucceed(int requestCode, @NonNull List<String> grantPermissions) {
                            getLocation(callbackContext);
                        }

                        @Override
                        public void onFailed(int requestCode, @NonNull List<String> deniedPermissions) {
                            callbackContext.error("权限不足");
                        }
                    })
                    .start();
            return true;
        }
        return false;
    }

    private void getLocation(final CallbackContext callbackContext) {
        TencentLocationManager locationManager = TencentLocationManager.getInstance(cordova.getActivity());
        locationManager.requestSingleFreshLocation(new TencentLocationListener() {
            @Override
            public void onLocationChanged(TencentLocation tencentLocation, int i, String s) {
                JSONObject jsonObject = new JSONObject();
                try {
                    jsonObject.put("latitude", tencentLocation.getLatitude());
                    jsonObject.put("longitude", tencentLocation.getLongitude());
                    callbackContext.success(jsonObject);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void onStatusUpdate(String s, int i, String s1) {

            }
        }, Looper.getMainLooper());
    }


}
