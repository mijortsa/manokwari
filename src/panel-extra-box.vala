using Gtk;

public class PanelExtraBox : PanelAbstractWindow {
    private const int COLUMN_WIDTH = 265;
    private const int TOP = 24;
    private bool inside;

    public signal void dismissed ();
    public signal void shown ();
    public signal void about_to_show_content ();

    PanelExtraHTML view;

    public PanelExtraBox () {

        // We need to register which events we are interested in
        add_events(Gdk.EventMask.ENTER_NOTIFY_MASK);
        add_events(Gdk.EventMask.LEAVE_NOTIFY_MASK);

        // Connecting some events, entered, leave and button pressed
        enter_notify_event.connect(mouse_entered);
        leave_notify_event.connect(mouse_leave);

        view = new PanelExtraHTML ();
        view.show_all ();
        add (view);
        set_keep_above (true);
        set_type_hint (Gdk.WindowTypeHint.POPUP_MENU);
        set_title ("_manokwari_menu_");
        set_visual (this.screen.get_rgba_visual ());

        Gdk.RGBA c = Gdk.RGBA();
        c.red = 0.0;
        c.blue = 0.0;
        c.green = 0.0;
        c.alpha = 0.0;
        override_background_color(StateFlags.NORMAL, c);
        set_app_paintable(true);

        PanelScreen.move_window (this, Gdk.Gravity.NORTH_EAST);

        view.start();

        hide ();

        button_press_event.connect((event) => {

        stdout.printf("xxx\n");
            // Only dismiss if within the area
            // TODO: multihead
            if (event.x > get_window().get_width()) {
                  shown ();
                return true;
            }
            return false;
        });

        screen_size_changed.connect (() =>  {
            PanelScreen.move_window (this, Gdk.Gravity.NORTH_EAST);
            queue_resize ();
        });

        map_event.connect (() => {
            shown ();
            PanelScreen.move_window (this, Gdk.Gravity.NORTH_EAST);
            get_window ().raise ();
            Utils.grab (this);
            view.triggerShowAnimation();
            return true;
        });

        key_press_event.connect ((e) => {
            if (Gdk.keyval_name(e.keyval) == "Escape") {
                if (view.handleEsc () == false) {
                    dismiss ();
                }
            } else if (Gdk.keyval_name(e.keyval) == "Print") {
                if (Utils.print_screen () == false) {
                    stdout.printf ("Unable to take screenshot\n");
                }
            }
            return false;
        });

    }

    public override void get_preferred_width (out int min, out int max) {
        min = max = COLUMN_WIDTH;
    }

    public override void get_preferred_height (out int min, out int max) {
        min = max = PanelScreen.get_primary_monitor_geometry ().height;
    }

// Mouse entered/leave control function extra panel
    public bool mouse_entered(Gdk.EventCrossing e) {
        inside = true;
        shown();
        return false;
    }

    public bool mouse_leave(Gdk.EventCrossing e) {
        inside = false;
        try_hide();
        return false;
    }


    private void dismiss () {
        if (visible) {
            stdout.printf("Extra box no dismissed \n");
            Utils.ungrab (this);
            shown ();
        }
    }

    bool real_hide () {
        hide ();
        return false;
    }

    public void try_hide () {
        view.triggerHideAnimation();
        GLib.Timeout.add (500, real_hide);
        dismissed ();
    }
}
