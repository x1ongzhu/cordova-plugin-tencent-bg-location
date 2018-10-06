package cn.x1ongzhu.tencentBgLocation;

import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.IBinder;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;

import com.google.gson.GsonBuilder;
import com.tencent.map.geolocation.TencentLocation;
import com.tencent.map.geolocation.TencentLocationListener;
import com.tencent.map.geolocation.TencentLocationManager;
import com.tencent.map.geolocation.TencentLocationRequest;

import org.json.JSONObject;

import java.util.Date;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;
import retrofit2.http.Field;
import retrofit2.http.FormUrlEncoded;
import retrofit2.http.GET;
import retrofit2.http.POST;
import retrofit2.http.Query;
import retrofit2.http.Url;

public class LocationService extends Service implements TencentLocationListener {
    private static final String TAG = "TencentBgLocation";
    private TencentLocationRequest request;
    private String url;
    private String carplate;
    private String handoverno;
    private api mApi;

    public LocationService() {
    }

    @Override
    public IBinder onBind(Intent intent) {
        // TODO: Return the communication channel to the service.
        throw new UnsupportedOperationException("Not yet implemented");
    }

    @Override
    public void onCreate() {
        super.onCreate();
        request = TencentLocationRequest.create();

    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Context context = getApplicationContext();
        TencentLocationManager locationManager = TencentLocationManager.getInstance(context);
        int error = locationManager.requestLocationUpdates(request, this);
        locationManager.requestSingleFreshLocation(this, Looper.getMainLooper());
        url = intent.getStringExtra("url");
        carplate = intent.getStringExtra("carplate");
        if (TextUtils.isEmpty(handoverno)) {
            handoverno = intent.getStringExtra("handoverno");
        } else {
            handoverno += "," + intent.getStringExtra("handoverno");
        }
        if (!(TextUtils.isEmpty(url) || TextUtils.isEmpty(carplate) || TextUtils.isEmpty(handoverno))) {
            if (mApi == null) {
                mApi = new Retrofit.Builder()
                        .baseUrl("http://naiyuan.izouma.com/")
                        .addConverterFactory(GsonConverterFactory.create(new GsonBuilder().create()))
                        .build()
                        .create(api.class);
            }
        }

        return super.onStartCommand(intent, flags, startId);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        stopWatchLocation();
    }

    private void stopWatchLocation() {
        TencentLocationManager locationManager = TencentLocationManager.getInstance(getApplicationContext());
        locationManager.removeUpdates(this);
    }

    @Override
    public void onLocationChanged(TencentLocation tencentLocation, int i, String s) {
        Log.d(TAG, "onLocationChanged:  latitude: " + tencentLocation.getLatitude() + ", longitude: " + tencentLocation.getLongitude());
        mApi.save(url, tencentLocation.getLatitude(), tencentLocation.getLongitude(), handoverno, carplate).enqueue(new Callback<JSONObject>() {
            @Override
            public void onResponse(Call<JSONObject> call, Response<JSONObject> response) {
                System.out.println("");
            }

            @Override
            public void onFailure(Call<JSONObject> call, Throwable t) {
                System.out.println("");
            }
        });
    }

    @Override
    public void onStatusUpdate(String s, int i, String s1) {
        Log.d(TAG, "onStatusUpdate: " + s + i + s1);
    }

    private interface api {
        @POST
        @FormUrlEncoded
        Call<JSONObject> save(@Url String url, @Field("latitude") double latitude, @Field("longitude") double longitude, @Field("handoverno") String handoverno, @Field("carplate") String carplate);
    }
}
