use bevy::prelude::*;

use crate::resources::counter::ClickCounter;
use crate::systems::counter::CounterText;

fn spacer() -> impl Scene {
    bsn! { Node { flex_grow: 1.0 } }
}

fn title_scene() -> impl Scene {
    bsn! {
        Text("Hello World")
        TextFont { font_size: FontSize::Px(28.0) }
        TextColor(Color::srgb(0.1, 0.1, 0.1))
    }
}

fn counter_text_scene() -> impl Scene {
    bsn! {
        #CounterText
        CounterText
        Text("You clicked 0 times")
        TextFont { font_size: FontSize::Px(18.0) }
        TextColor(Color::srgb(0.4, 0.4, 0.4))
    }
}

fn fab_scene() -> impl Scene {
    bsn! {
        #FABButton
        Button
        Node {
            width: px(56),
            height: px(56),
            border_radius: BorderRadius::all(px(28)),
            align_items: AlignItems::Center,
            justify_content: JustifyContent::Center,
            margin: UiRect::bottom(px(32)),
        }
        BackgroundColor(Color::srgb(0.2, 0.6, 1.0))
        Children [
            Text("+")
            TextFont { font_size: FontSize::Px(28.0) }
            TextColor(Color::WHITE)
        ]
        on(|_: On<Pointer<Press>>, mut counter: ResMut<ClickCounter>| {
            counter.0 += 1;
        })
    }
}

fn ui_root() -> impl Scene {
    bsn! {
        #Root
        Node {
            width: percent(100),
            height: percent(100),
            flex_direction: FlexDirection::Column,
            align_items: AlignItems::Center,
        }
        BackgroundColor(Color::srgb(0.96, 0.96, 0.98))
        Children [
            spacer(),
            title_scene(),
            Node { height: px(24) },
            counter_text_scene(),
            spacer(),
            fab_scene(),
        ]
    }
}

pub fn app_scene() -> impl SceneList {
    bsn_list![Camera2d, ui_root()]
}
