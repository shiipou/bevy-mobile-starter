use bevy::prelude::*;

use crate::resources::counter::ClickCounter;

#[derive(Component, Default, Clone)]
pub struct CounterText;

pub fn update_counter_text(
    counter: Res<ClickCounter>,
    mut query: Query<&mut Text, With<CounterText>>,
) {
    if counter.is_changed() {
        for mut text in query.iter_mut() {
            *text = Text::new(format!("You clicked {} times", counter.0));
        }
    }
}
