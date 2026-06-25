use bevy::prelude::*;

#[derive(Resource, Default, Clone, Debug)]
pub struct ClickCounter(pub usize);
