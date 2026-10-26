package dumpkeys;

import android.view.KeyEvent;
import java.lang.reflect.Field;

public class DumpKeys {
    public static void main(String[] args) {
        Field[] fields = KeyEvent.class.getFields();
        for (Field f : fields) {
            if (f.getName().startsWith("KEYCODE_") && f.getType() == int.class) {
                try {
                    int val = f.getInt(null);
                    if (f.getName().contains("TCL") || f.getName().contains("HOME") || f.getName().contains("CHANNEL") || f.getName().contains("APP") || f.getName().contains("GUIDE")) {
                        System.out.println(f.getName() + "=" + val);
                    }
                } catch (Exception e) {}
            }
        }
    }
}
