/*   consult('/Users/lalogonzalez/repos/Curse/curse.pl').   */

:- dynamic i_am_at/1, at/2, holding/1, talked/1, examined/1, time/1.
:- retractall(at(_, _)), retractall(i_am_at(_)), retractall(alive(_)).

/* Starting position */
 
i_am_at(church_plaza).


/* Definition of world map */

path(church_plaza, s, main_plaza).
path(main_plaza, n, church_plaza).

path(church_plaza, n, church_altar_room).
path(church_altar_room, s, church_plaza).

path(church_altar_room, w, church_study).
path(church_study, e, church_altar_room).

path(church_altar_room, e, church_basement).
path(church_basement, w, church_altar_room).

path(church_plaza, w, your_house).
path(your_house, e, church_plaza).

path(main_plaza, e, inn).
path(inn, w, main_plaza).

path(main_plaza, s, swamp).
path(swamp, n, main_plaza).

path(swamp, e, witch_cabin).
path(witch_cabin, w, swamp).

path(swamp, w, bald_cypress_tree_family).
path(bald_cypress_tree_family, e, swamp).


/* Definition of objects starting position */

at(beggar, main_plaza).
at(beer_tankard, inn).
at(witch, witch_cabin).
at(bark_piece, bald_cypress_tree_family).
at(house_key, church_study).
at(prayer_book, your_house).


/* Definition of objects revealed with talk_to */

talkable(beggar).
in(beggar, compass).
requires(compass, beer).

%talkable(witch).
%in(witch, potion).
requires(bark_piece).


/* Different scenarios that can happen when taking something */

take(X) :-
        holding(X),
        write('You are already holding that'),
        !, nl.

take(X) :-
        requires(X,Y), \+ holding(Y),
        write('You can''t take the '), write(X), write(' yet. You need to find '), write(Y), write(' first.'),
        !, nl.

take(X) :-
        talkable(X),
        write('Umm... you cannot take people. Remember what happened to the last priest who tried to do that...'), !, nl.

take(X) :-
        i_am_at(Place),
        at(X, Place),
        retract(at(X, Place)),
        assert(holding(X)),
        write('OK.'), 
        !, nl.

take(_) :-
        write('I don''t see it here.'),
        nl.


i :- write('Inventory:'), nl,
     holding(X),
     write(X), nl,
     fail.

i :- \+ holding(_), write('Your inventory is empty.'), !, nl.

i.


/* Defines start of game */

start :-
        controls,
        introduction,
        look.


controls :-
        nl,
        write('-------------------------------------'), nl,
        write('Enter commands using standard Prolog syntax.'), nl,
        write('Available commands are:'), nl,
        write('start.             -- to start the game.'), nl,
        write('n.  s.  e.  w.     -- to move in given direction.'), nl,
        /*write('take(Object).      -- to pick up an object.'), nl,
        write('drop(Object).      -- to put down an object.'), nl,
        write('i.                 -- to check your inventory.'), nl,*/
        write('talk(Person)    -- to talk to people.'), nl,
        write('look.              -- to look around you again.'), nl,
        write('controls.      -- to show controls again.'), nl,
        write('halt.              -- to end game and quit.'), nl,
        write('-------------------------------------'), nl,
        nl.

introduction :-
        nl,
        write('The year is 1310. You are the town of Eadburgh''s local priest.'), nl, %sleep(2),
        write('Lately, people have been disappearing, there have been rumors of a'), nl, %sleep(2),
        write('vampiric curse menacing the town. You can trust no one.'), nl, nl, %sleep(4),

        write('The time is late at night when you hear someone knocking at your door...'), nl, %sleep(2),
        write('asking for help. As the priest, you cannot deny help to townspeople.'), nl, %sleep(2),
        write('You open the door to find a cloacked figure who suddenly attacks you,'), nl, %sleep(2),
        write('too fast to even try to defend yourself!'), nl, nl, %sleep(4),

        write('You black out...'), nl, nl, %sleep(5),

        write('You wake, lying on the floor before your church. You feel an acute pain'), nl, %sleep(2),
        write('to the neck. You touch it with your fingers to discover you have been'), nl, %sleep(2),
        write('bitten! "I''ve been cursed with vampirism", you figure, "I''ve got to'), nl, %sleep(2),
        write('find a way to revert the curse, and kill whatever thing cursed me." '), nl, %sleep(2),
        write('-------------------------------------'), nl, %sleep(5),
        nl.


/* Predicate that reveals desctiption of current position and people/objects found there. */

look :-
        i_am_at(Place),
        describe(Place),
        nl,
        print_objects_found_in(Place),
        nl.


print_objects_found_in(Place) :-
        at(X, Place),
        write('There is a '), write(X), write(' here.'), nl,
        fail.
        
print_objects_found_in(_).


/* Talked to people drop other objects. Without conversation, objects dont show up upon look */

talk_to(beggar) :-
        talkable(beggar),
        assert(talked(beggar)),
        in(beggar, Y),
        write('What''s the matter Reverend'), nl,
        write('The beggar dropped a '), write(Y), write(' for you to take!'), nl,
        i_am_at(Place),
        assert(at(Y,Place)),
        !, nl.

talk_to(witch) :-
        talkable(witch),
        assert(talked(witch)),
        in(witch, Y),
        write('What''s the matter Reverend'), nl,
        write('The witch dropped a '), write(Y), write(' for you to take!'), nl,
        i_am_at(Place),
        assert(at(Y,Place)),
        !, nl.

/*talk_to(X) :-
        talkable(X),
        assert(talked(X)),
        in(X, Y),
        write('The '), write(X), write(' dropped a '), write(Y), write(' for you to take!'), nl,
        i_am_at(Place),
        assert(at(Y,Place)),
        !, nl.*/

talk_to(X) :-
        talkable(X),
        assert(talked(X)),
        write('There''s nothing special about '), write(X), write('.'), !, nl.

talk_to(_) :-
        write('You can''t talk to inanimate objects.'), nl.


/* These rules define the direction letters as calls to go/1. */

n :- go(n).

s :- go(s).

e :- go(e).

w :- go(w).


/* This rule tells how to move in a given direction. */

go(Direction) :-
        i_am_at(Here), nl,
        path(Here, Direction, There),
        retract(i_am_at(Here)),
        assert(i_am_at(There)),
        !, look.

go(_) :-
        write('You cannot go that way.').


/* These rules print descriptions about the rooms that make up the world. */

describe(church_plaza) :-
        write('You are in the church plaza.'), nl,
        write('You can hear violent noises coming from inside the church.'), nl, nl,
        write('To the north is the church.'), nl,
        write('To the south is the main plaza.'), nl,
        write('To the west is your house.'),
        nl.

describe(main_plaza) :-
        write('You are in the main plaza'), nl, nl,
        write('To the north is the church plaza.'), nl,
        write('To the south is the town''s exit. Outside there is a path that leads to the swamp'), nl,
        write('To the east is the inn.'),
        nl.

describe(church_altar_room) :-
        write('You are in the church''s altar room.'), nl, nl,
        write('To the south is the exit to church plaza.'), nl,
        write('To the east are the stair to descend to the basement.'), nl,
        write('To the west is your study.'),
        nl.

describe(church_study) :-
        write('You are in your study.'), nl, nl,
        write('To the east is the exit to the altar room.'),
        nl.

describe(church_basement) :-
        write('You are in the church basement.'), nl, nl,
        write('To the east are the stairs to exit back to the altar room.'),
        nl.

describe(your_house) :-
        write('You are home.'), nl, nl,
        write('To the east is the exit to church plaza.'),
        nl.

describe(inn) :-
        write('You are at the inn.'), nl, nl,
        write('To the west is the exit to main plaza.'),
        nl.

describe(swamp) :-
        write('You are at the swamp.'), nl, nl,
        write('To the north is the path back to Eadburgh''s main plaza.'), nl,
        write('To the east you see an old cabin, almost consumed by the swamp''s vegetation.'), nl,
        write('To the west is a Bald Cypress tree family.'),
        nl.

describe(witch_cabin) :-
        write('You are inside the witch''s cabin. There seems to be no one home.'), nl, nl,
        write('To the west is the exit back to the swamp.'),
        nl.

describe(bald_cypress_tree_family) :-
        write('You are surrounded by Bald Cypress trees.'), nl,
        write('To the east is the exit back to the swamp.'),
        nl.

