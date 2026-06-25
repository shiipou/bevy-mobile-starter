pub mod app;
pub mod resources;
pub mod systems;
pub mod ui;

use app::plugin;
use bevy::app::App;

pub fn create_app() -> App {
    let mut app = App::new();
    plugin::build_app(&mut app);
    app
}

#[cfg(target_os = "android")]
mod android_entry {
    #[unsafe(no_mangle)]
    fn android_main(app: bevy::android::android_activity::AndroidApp) {
        let _ = bevy::android::ANDROID_APP.set(app);
        unsafe { std::env::set_var("RUST_BACKTRACE", "1") };
        android_logger::init_once(
            android_logger::Config::default()
                .with_max_level(log::LevelFilter::Info)
                .with_tag("bevy-mobile-starter"),
        );

        let mut bevy_app = super::create_app();
        bevy_app.run();
    }
}

#[cfg(target_os = "ios")]
mod ios_entry {
    #[no_mangle]
    pub extern "C" fn main_rs() {
        let mut app = super::create_app();
        app.run();
    }
}
