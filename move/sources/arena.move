module challenge::arena;

use challenge::hero;
use challenge::hero::Hero;
use sui::event;

// ========= STRUCTS =========

public struct Arena has key, store {
    id: UID,
    warrior: Hero,
    owner: address,
}

// ========= EVENTS =========

public struct ArenaCreated has copy, drop {
    arena_id: ID,
    timestamp: u64,
}

public struct ArenaCompleted has copy, drop {
    winner_hero_id: ID,
    loser_hero_id: ID,
    timestamp: u64,
}

// ========= FUNCTIONS =========

public fun create_arena(hero: Hero, ctx: &mut TxContext) {

    // TODO: Create an arena object
        // Hints:
        // Use object::new(ctx) for unique ID
        // Set warrior field to the hero parameter
        // Set owner to ctx.sender()
    // TODO: Emit ArenaCreated event with arena ID and timestamp (Don't forget to use ctx.epoch_timestamp_ms(), object::id(&arena))
    // TODO: Use transfer::share_object() to make it publicly tradeable
    let arena = Arena {
        id: sui::object::new(ctx),
        warrior: hero,
        owner: sui::tx_context::sender(ctx),
    };
    event::emit(ArenaCreated {
        arena_id: sui::object::id(&arena),
        timestamp: sui::tx_context::epoch_timestamp_ms(ctx),
    });
    sui::transfer::share_object(arena);
}

#[allow(lint(self_transfer))]
public fun battle(hero: Hero, arena: Arena, ctx: &mut TxContext) {
    
    // TODO: Implement battle logic
        // Hints:
        // Destructure arena to get id, warrior, and owner
    // TODO: Compare hero.hero_power() with warrior.hero_power()
        // Hints: 
        // If hero wins: both heroes go to ctx.sender()
        // If warrior wins: both heroes go to battle place owner
    // TODO:  Emit ArenaCompleted event with winner/loser IDs (Don't forget to use object::id(&warrior) or object::id(&hero) ). 
        // Hints:  
        // You have to emit this inside of the if else statements
    // TODO: Delete the battle place ID 
    let Arena { id, warrior, owner } = arena;
    let hero_id = sui::object::id(&hero);
    let warrior_id = sui::object::id(&warrior);

    if (hero::hero_power(&hero) > hero::hero_power(&warrior)) {
        event::emit(ArenaCompleted {
            winner_hero_id: hero_id,
            loser_hero_id: warrior_id,
            timestamp: sui::tx_context::epoch_timestamp_ms(ctx),
        });
        sui::transfer::public_transfer(hero, sui::tx_context::sender(ctx));
        sui::transfer::public_transfer(warrior, sui::tx_context::sender(ctx));
    } else {
        event::emit(ArenaCompleted {
            winner_hero_id: warrior_id,
            loser_hero_id: hero_id,
            timestamp: sui::tx_context::epoch_timestamp_ms(ctx),
        });
        sui::transfer::public_transfer(hero, owner);
        sui::transfer::public_transfer(warrior, owner);
    };

    sui::object::delete(id);
}

