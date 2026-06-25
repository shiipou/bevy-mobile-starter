use bevy::prelude::*;
use bevy::window::{PresentMode, WindowMode, WindowResolution};

use crate::ui::scenes;

pub fn build_app(app: &mut App) {
    let window_plugin = if cfg!(target_os = "android") || cfg!(target_os = "ios") {
        WindowPlugin {
            primary_window: Some(Window {
                title: "Bevy Mobile Starter".into(),
                mode: WindowMode::Windowed,
                present_mode: PresentMode::AutoVsync,
                ..Default::default()
            }),
            ..Default::default()
        }
    } else {
        WindowPlugin {
            primary_window: Some(Window {
                title: "Bevy Mobile Starter".into(),
                resolution: WindowResolution::new(390, 844),
                resizable: false,
                mode: WindowMode::Windowed,
                present_mode: PresentMode::AutoVsync,
                ..Default::default()
            }),
            ..Default::default()
        }
    };

    app.add_plugins(DefaultPlugins.set(window_plugin))
        .add_plugins(StarterPlugin);
}

struct StarterPlugin;

impl Plugin for StarterPlugin {
    fn build(&self, app: &mut App) {
        app.insert_resource(crate::resources::counter::ClickCounter::default())
            .add_systems(Startup, spawn_ui)
            .add_systems(
                Update,
                crate::systems::counter::update_counter_text,
            );
    }
}

fn spawn_ui(mut commands: Commands) {
    commands.spawn_scene_list(scenes::app_scene());
}
