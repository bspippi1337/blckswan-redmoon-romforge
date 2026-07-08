package os.blckswan.about;

import android.app.Activity;
import android.graphics.Typeface;
import android.os.Bundle;
import android.util.TypedValue;
import android.view.Gravity;
import android.widget.LinearLayout;
import android.widget.TextView;

public class MainActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setGravity(Gravity.CENTER);
        int padding = (int) TypedValue.applyDimension(
                TypedValue.COMPLEX_UNIT_DIP, 24, getResources().getDisplayMetrics());
        root.setPadding(padding, padding, padding, padding);

        TextView title = new TextView(this);
        title.setText("BLCKSWAN OS 42\nRED MOON");
        title.setGravity(Gravity.CENTER);
        title.setTypeface(Typeface.DEFAULT_BOLD);
        title.setTextSize(TypedValue.COMPLEX_UNIT_SP, 28);

        TextView body = new TextView(this);
        body.setText(
                "This APK is injected into product.img by the FlashROM pipeline.\n\n" +
                "Version: 42.0-redmoon\n" +
                "Codename: Restless\n" +
                "Edition: RED MOON");
        body.setGravity(Gravity.CENTER);
        body.setTextSize(TypedValue.COMPLEX_UNIT_SP, 16);

        root.addView(title);
        root.addView(body);
        setContentView(root);
    }
}
