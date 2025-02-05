module Playground exposing
    ( picture, animation, game
    , Shape, circle, oval, square, rectangle, triangle, pentagon, hexagon, octagon, polygon
    , words
    , image, Atlas, sprite
    , move, moveUp, moveDown, moveLeft, moveRight, moveX, moveY
    , scale, rotate, fade, flipHorizontally, flipVertically
    , group
    , Time, spin, wave, zigzag
    , Computer, Mouse, Screen, Keyboard, toX, toY, toXY
    , Color, rgb, red, orange, yellow, green, blue, purple, brown
    , lightRed, lightOrange, lightYellow, lightGreen, lightBlue, lightPurple, lightBrown
    , darkRed, darkOrange, darkYellow, darkGreen, darkBlue, darkPurple, darkBrown
    , white, lightGrey, grey, darkGrey, lightCharcoal, charcoal, darkCharcoal, black
    , lightGray, gray, darkGray
    , Number
    , application
    ,  UserMsg(..)
       --
       --
       --
       --
       --

    )

{-|


# Playgrounds

@docs picture, animation, game


# Shapes

@docs Shape, circle, oval, square, rectangle, triangle, pentagon, hexagon, octagon, polygon


# Words

@docs words


# Images

@docs image, Atlas, atlas, sprite


# Move Shapes

@docs move, moveUp, moveDown, moveLeft, moveRight, moveX, moveY


# Customize Shapes

@docs scale, rotate, fade, flipHorizontally, flipVertically


# Groups

@docs group


# Time

@docs Time, spin, wave, zigzag


# Computer

@docs Computer, Mouse, Screen, Keyboard, toX, toY, toXY


# Colors

@docs Color, rgb, red, orange, yellow, green, blue, purple, brown


### Light Colors

@docs lightRed, lightOrange, lightYellow, lightGreen, lightBlue, lightPurple, lightBrown


### Dark Colors

@docs darkRed, darkOrange, darkYellow, darkGreen, darkBlue, darkPurple, darkBrown


### Shades of Grey

@docs white, lightGrey, grey, darkGrey, lightCharcoal, charcoal, darkCharcoal, black


### Alternate Spellings of Gray

@docs lightGray, gray, darkGray


### Numbers

@docs Number


### Interacting with the outside world

@docs application, Msg

-}

import Browser
import Browser.Dom as Dom
import Browser.Events as E
import Dict
import Html
import Html.Attributes as H
import Json.Decode as D
import Set
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Svg.Lazy exposing (lazy)
import Task
import Time



-- PICTURE


{-| Make a picture! Here is a picture of a triangle with an eyeball:

    import Playground exposing (..)

    main =
        picture
            [ triangle green 150
            , circle white 40
            , circle black 10
            ]

-}
picture : List Shape -> Program () Screen ( Int, Int )
picture shapes =
    let
        init () =
            ( toScreen 600 600, Cmd.none )

        view screen =
            { title = "Playground"
            , body = [ render [] screen shapes ]
            }

        update ( width, height ) _ =
            ( toScreen (toFloat width) (toFloat height)
            , Cmd.none
            )

        subscriptions _ =
            E.onResize Tuple.pair
    in
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- COMPUTER


{-| When writing a [`game`](#game), you can look up all sorts of information
about your computer:

  - [`Mouse`](#Mouse) - Where is the mouse right now?
  - [`Keyboard`](#Keyboard) - Are the arrow keys down?
  - [`Screen`](#Screen) - How wide is the screen?
  - [`Time`](#Time) - What time is it right now?

So you can use expressions like `computer.mouse.x` and `computer.keyboard.enter`
in games where you want some mouse or keyboard interaction.

-}
type alias Computer =
    { mouse : Mouse
    , keyboard : Keyboard
    , screen : Screen
    , time : Time
    }



-- MOUSE


{-| Figure out what is going on with the mouse.

You could draw a circle around the mouse with a program like this:

    import Playground exposing (..)

    main =
        game view update 0

    view computer memory =
        [ circle yellow 40
            |> moveX computer.mouse.x
            |> moveY computer.mouse.y
        ]

    update computer memory =
        memory

You could also use `computer.mouse.down` to change the color of the circle
while the mouse button is down.

-}
type alias Mouse =
    { x : Number
    , y : Number
    , down : Bool
    , click : Bool
    }


{-| A number like `1` or `3.14` or `-120`.
-}
type alias Number =
    Float



-- KEYBOARD


{-| Figure out what is going on with the keyboard.

If someone is pressing the UP and RIGHT arrows, you will see a value like this:

    { up = True
    , down = False
    , left = False
    , right = True
    , space = False
    , enter = False
    , shift = False
    , backspace = False
    , keys = Set.fromList [ "ArrowUp", "ArrowRight" ]
    }

So if you want to move a character based on arrows, you could write an update
like this:

    update computer y =
        if computer.keyboard.up then
            y + 1

        else
            y

Check out [`toX`](#toX) and [`toY`](#toY) which make this even easier!

**Note:** The `keys` set will be filled with the name of all keys which are
down right now. So you will see things like `"a"`, `"b"`, `"c"`, `"1"`, `"2"`,
`"Space"`, and `"Control"` in there. Check out [this list][list] to see the
names used for all the different special keys! From there, you can use
[`Set.member`][member] to check for whichever key you want. E.g.
`Set.member "Control" computer.keyboard.keys`.

[list]: https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key/Key_Values
[member]: /packages/elm/core/latest/Set#member

-}
type alias Keyboard =
    { up : Bool
    , down : Bool
    , left : Bool
    , right : Bool
    , space : Bool
    , enter : Bool
    , shift : Bool
    , backspace : Bool
    , keys : Set.Set String
    }


{-| Turn the LEFT and RIGHT arrows into a number.

    toX { left = False, right = False, ... } == 0
    toX { left = True , right = False, ... } == -1
    toX { left = False, right = True , ... } == 1
    toX { left = True , right = True , ... } == 0

So to make a square move left and right based on the arrow keys, we could say:

    import Playground exposing (..)

    main =
        game view update 0

    view computer x =
        [ square green 40
            |> moveX x
        ]

    update computer x =
        x + toX computer.keyboard

-}
toX : Keyboard -> Number
toX keyboard =
    (if keyboard.right then
        1

     else
        0
    )
        - (if keyboard.left then
            1

           else
            0
          )


{-| Turn the UP and DOWN arrows into a number.

    toY { up = False, down = False, ... } == 0
    toY { up = True , down = False, ... } == 1
    toY { up = False, down = True , ... } == -1
    toY { up = True , down = True , ... } == 0

This can be used to move characters around in games just like [`toX`](#toX):

    import Playground exposing (..)

    main =
        game view update ( 0, 0 )

    view computer ( x, y ) =
        [ square blue 40
            |> move x y
        ]

    update computer ( x, y ) =
        ( x + toX computer.keyboard
        , y + toY computer.keyboard
        )

-}
toY : Keyboard -> Number
toY keyboard =
    (if keyboard.up then
        1

     else
        0
    )
        - (if keyboard.down then
            1

           else
            0
          )


{-| If you just use `toX` and `toY`, you will move diagonal too fast. You will go
right at 1 pixel per update, but you will go up/right at 1.41421 pixels per
update.

So `toXY` turns the arrow keys into an `(x,y)` pair such that the distance is
normalized:

    toXY { up = True , down = False, left = False, right = False, ... } == (1, 0)
    toXY { up = True , down = False, left = False, right = True , ... } == (0.707, 0.707)
    toXY { up = False, down = False, left = False, right = True , ... } == (0, 1)

Now when you go up/right, you are still going 1 pixel per update.

    import Playground exposing (..)

    main =
        game view update ( 0, 0 )

    view computer ( x, y ) =
        [ square green 40
            |> move x y
        ]

    update computer ( x, y ) =
        let
            ( dx, dy ) =
                toXY computer.keyboard
        in
        ( x + dx, y + dy )

-}
toXY : Keyboard -> ( Number, Number )
toXY keyboard =
    let
        x =
            toX keyboard

        y =
            toY keyboard
    in
    if x /= 0 && y /= 0 then
        ( x / squareRootOfTwo, y / squareRootOfTwo )

    else
        ( x, y )


squareRootOfTwo : Number
squareRootOfTwo =
    sqrt 2



-- SCREEN


{-| Get the dimensions of the screen. If the screen is 800 by 600, you will see
a value like this:

    { width = 800
    , height = 600
    , top = 300
    , left = -400
    , right = 400
    , bottom = -300
    }

This can be nice when used with [`moveY`](#moveY) if you want to put something
on the bottom of the screen, no matter the dimensions.

-}
type alias Screen =
    { width : Number
    , height : Number
    , top : Number
    , left : Number
    , right : Number
    , bottom : Number
    }



-- TIME


{-| The current time.

Helpful when making an [`animation`](#animation) with functions like
[`spin`](#spin), [`wave`](#wave), and [`zigzag`](#zigzag).

-}
type Time
    = Time Time.Posix


{-| Create an angle that cycles from 0 to 360 degrees over time.

Here is an [`animation`](#animation) with a spinning triangle:

    import Playground exposing (..)

    main =
        animation view

    view time =
        [ triangle orange 50
            |> rotate (spin 8 time)
        ]

It will do a full rotation once every eight seconds. Try changing the `8` to
a `2` to make it do a full rotation every two seconds. It moves a lot faster!

-}
spin : Number -> Time -> Number
spin period time =
    360 * toFrac period time


{-| Smoothly wave between two numbers.

Here is an [`animation`](#animation) with a circle that resizes:

    import Playground exposing (..)

    main =
        animation view

    view time =
        [ circle lightBlue (wave 50 90 7 time)
        ]

The radius of the circle will cycles between 50 and 90 every seven seconds.
It kind of looks like it is breathing.

-}
wave : Number -> Number -> Number -> Time -> Number
wave lo hi period time =
    lo + (hi - lo) * (1 + cos (turns (toFrac period time))) / 2


{-| Zig zag between two numbers.

Here is an [`animation`](#animation) with a rectangle that tips back and forth:

    import Playground exposing (..)

    main =
        animation view

    view time =
        [ rectangle lightGreen 20 100
            |> rotate (zigzag -20 20 4 time)
        ]

It gets rotated by an angle. The angle cycles from -20 degrees to 20 degrees
every four seconds.

-}
zigzag : Number -> Number -> Number -> Time -> Number
zigzag lo hi period time =
    lo + (hi - lo) * abs (2 * toFrac period time - 1)


toFrac : Float -> Time -> Float
toFrac period (Time posix) =
    let
        ms =
            Time.posixToMillis posix

        p =
            period * 1000
    in
    toFloat (modBy (round p) ms) / p



-- ANIMATION


{-| Create an animation!

Once you get comfortable using [`picture`](#picture) to layout shapes, you can
try out an `animation`. Here is square that zigzags back and forth:

    import Playground exposing (..)

    main =
        animation view

    view time =
        [ square blue 40
            |> moveX (zigzag -100 100 2 time)
        ]

We need to define a `view` to make our animation work.

Within `view` we can use functions like [`spin`](#spin), [`wave`](#wave),
and [`zigzag`](#zigzag) to move and rotate our shapes.

-}
animation : (Time -> List Shape) -> Program () Animation Msg
animation viewFrame =
    let
        init () =
            ( Animation (toScreen 600 600) (Time (Time.millisToPosix 0))
            , Task.perform GotViewport Dom.getViewport
            )

        view (Animation screen time) =
            { title = "Playground"
            , body = [ render [] screen (viewFrame time) ]
            }

        update msg model =
            ( animationUpdate msg model
            , Cmd.none
            )

        subscriptions (Animation _ _) =
            animationSubscriptions
    in
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type Animation
    = Animation Screen Time


animationSubscriptions : Sub Msg
animationSubscriptions =
    Sub.batch
        [ E.onResize Resized
        , E.onAnimationFrame Tick
        ]


animationUpdate : Msg -> Animation -> Animation
animationUpdate msg ((Animation s t) as state) =
    case msg of
        Tick posix ->
            Animation s (Time posix)

        GotViewport { viewport } ->
            Animation (toScreen viewport.width viewport.height) t

        Resized w h ->
            Animation (toScreen (toFloat w) (toFloat h)) t

        KeyChanged _ _ ->
            state

        MouseMove _ _ ->
            state

        MouseClick ->
            state

        MouseButton _ ->
            state



-- GAME


{-| Create a game!

Once you get comfortable with [`animation`](#animation), you can try making a
game with the keyboard and mouse. Here is an example of a green square that
just moves to the right:

    import Playground exposing (..)

    main =
        game view update 0

    view computer offset =
        [ square green 40
            |> moveRight offset
        ]

    update computer offset =
        offset + 0.03

This shows the three important parts of a game:

1.  `memory` - makes it possible to store information. So with our green square,
    we save the `offset` in memory. It starts out at `0`.
2.  `view` - lets us say which shapes to put on screen. So here we move our
    square right by the `offset` saved in memory.
3.  `update` - lets us update the memory. We are incrementing the `offset` by
    a tiny amount on each frame.

The `update` function is called about 60 times per second, so our little
changes to `offset` start to add up pretty quickly!

This game is not very fun though! Making a `game` also gives you access to the
[`Computer`](#Computer), so you can use information about the [`Mouse`](#Mouse)
and [`Keyboard`](#Keyboard) to make it interactive! So here is a red square that
moves based on the arrow keys:

    import Playground exposing (..)

    main =
        game view update ( 0, 0 )

    view computer ( x, y ) =
        [ square red 40
            |> move x y
        ]

    update computer ( x, y ) =
        ( x + toX computer.keyboard
        , y + toY computer.keyboard
        )

Notice that in the `update` we use information from the keyboard to update the
`x` and `y` values. These building blocks let you make pretty fancy games!

-}
game : (Computer -> memory -> List Shape) -> (Computer -> memory -> memory) -> memory -> Program () (Game memory) Msg
game viewMemory updateMemory initialMemory =
    let
        init () =
            ( Game   initialMemory initialComputer
            , Task.perform GotViewport Dom.getViewport
            )

        view (Game memory computer) =
            { title = "Playground"
            , body = [ render [] computer.screen (viewMemory computer memory) ]
            }

        update msg model =
            ( gameUpdate updateMemory msg model
            , Cmd.none
            )

        subscriptions (Game _ _) =
            gameSubscriptions
    in
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


initialComputer : Computer
initialComputer =
    { mouse = Mouse 0 0 False False
    , keyboard = emptyKeyboard
    , screen = toScreen 600 600
    , time = Time (Time.millisToPosix 0)
    }



-- SUBSCRIPTIONS


gameSubscriptions : Sub Msg
gameSubscriptions =
    Sub.batch
        [ E.onResize Resized
        , E.onKeyUp (D.map (KeyChanged False) (D.field "key" D.string))
        , E.onKeyDown (D.map (KeyChanged True) (D.field "key" D.string))
        , E.onAnimationFrame Tick
        , E.onClick (D.succeed MouseClick)
        , E.onMouseDown (D.succeed (MouseButton True))
        , E.onMouseUp (D.succeed (MouseButton False))
        , E.onMouseMove (D.map2 MouseMove (D.field "pageX" D.float) (D.field "pageY" D.float))
        ]



-- GAME HELPERS


type Game memory
    = Game memory Computer


type Msg
    = KeyChanged Bool String
    | Tick Time.Posix
    | GotViewport Dom.Viewport
    | Resized Int Int
    | MouseMove Float Float
    | MouseClick
    | MouseButton Bool


gameUpdate : (Computer -> memory -> memory) -> Msg -> Game memory -> Game memory
gameUpdate updateMemory msg (Game memory computer) =
    case msg of
        Tick time ->
            Game (updateMemory computer memory) <|
                if computer.mouse.click then
                    { computer | time = Time time, mouse = mouseClick False computer.mouse }

                else
                    { computer | time = Time time }

        GotViewport { viewport } ->
            Game memory { computer | screen = toScreen viewport.width viewport.height }

        Resized w h ->
            Game memory { computer | screen = toScreen (toFloat w) (toFloat h) }

        KeyChanged isDown key ->
            Game memory { computer | keyboard = updateKeyboard isDown key computer.keyboard }

        MouseMove pageX pageY ->
            let
                x =
                    computer.screen.left + pageX

                y =
                    computer.screen.top - pageY
            in
            Game memory { computer | mouse = mouseMove x y computer.mouse }

        MouseClick ->
            Game memory { computer | mouse = mouseClick True computer.mouse }

        MouseButton isDown ->
            Game memory { computer | mouse = mouseDown isDown computer.mouse }



-- SCREEN HELPERS


toScreen : Float -> Float -> Screen
toScreen width height =
    { width = width
    , height = height
    , top = height / 2
    , left = -width / 2
    , right = width / 2
    , bottom = -height / 2
    }



-- MOUSE HELPERS


mouseClick : Bool -> Mouse -> Mouse
mouseClick bool mouse =
    { mouse | click = bool }


mouseDown : Bool -> Mouse -> Mouse
mouseDown bool mouse =
    { mouse | down = bool }


mouseMove : Float -> Float -> Mouse -> Mouse
mouseMove x y mouse =
    { mouse | x = x, y = y }



-- KEYBOARD HELPERS


emptyKeyboard : Keyboard
emptyKeyboard =
    { up = False
    , down = False
    , left = False
    , right = False
    , space = False
    , enter = False
    , shift = False
    , backspace = False
    , keys = Set.empty
    }


updateKeyboard : Bool -> String -> Keyboard -> Keyboard
updateKeyboard isDown key keyboard =
    let
        keys =
            if isDown then
                Set.insert key keyboard.keys

            else
                Set.remove key keyboard.keys
    in
    case key of
        " " ->
            { keyboard | keys = keys, space = isDown }

        "Enter" ->
            { keyboard | keys = keys, enter = isDown }

        "Shift" ->
            { keyboard | keys = keys, shift = isDown }

        "Backspace" ->
            { keyboard | keys = keys, backspace = isDown }

        "ArrowUp" ->
            { keyboard | keys = keys, up = isDown }

        "ArrowDown" ->
            { keyboard | keys = keys, down = isDown }

        "ArrowLeft" ->
            { keyboard | keys = keys, left = isDown }

        "ArrowRight" ->
            { keyboard | keys = keys, right = isDown }

        _ ->
            { keyboard | keys = keys }



-- APPLICATION


{-| Create a game that can talk to the outside world!

Once you get comfortable with [`game`](#game), you may want to talk to the outside world.
Maybe you want to have save files? Or play some audio?
In the future you might want to talk to a server to have a scoreboard!

`application` lets you use all the libraries in the Elm ecosystem (and more),
by expanding the type of the `update` function, by allowing you to provide
your own events, via `subscriptions`.

You should take some time to walk through the [Elm Guide](https://guide.elm-lang.org/) first,
to get yourself acquanted with Commands and Subscriptions.

As you progress through it, you will find the familiar `update` and `view` functions,
although the latter will produce `Html`, they work exactly the same way as in `elm-playground`!
`memory` is called a Model there, but it serves the same purpose.

The `update` function now takes another argument: the message that is coming from the outside world
to your game. It can be either a `Frame` (usually around `16` times per second),
or an `UserMsg` with your custom message. If you don't need a message you can ignore the argument.

The `update` function also produces an additional result: a `Cmd`.
Again, you should read the [Elm Guide](https://guide.elm-lang.org/) and get familiar with Commands.

You may wonder if this could be expanded to accept flags, or to produce a `Cmd` on initialization.
This is actually unnecessary. You can structure your `application` like this instead:

    type FlagsAndInits
        = WaitingFlags
        | Running { ... }

    type Msg =
        | GotFlags Flags
        | ...

    update msg computer memory =
        case msg of
            UserMsg (GotFlags flags) ->
                initWithFlagsAndCmd flags

The last difference is that your `render` function should also return the page title.

-}
application :
    { view : Computer -> memory -> ( String, List Shape )
    , update : UserMsg msg -> Computer -> memory -> ( memory, Cmd msg )
    , subscriptions : memory -> Sub msg
    , init : memory
    , atlases : List Atlas
    }
    -> Program () (Game memory) (ExternalMsg msg)
application userProgram =
    let
        init () =
            ( Game userProgram.init initialComputer
            , Cmd.map Internal <| Task.perform GotViewport Dom.getViewport
            )

        view (Game memory computer) =
            let
                ( title, shapes ) =
                    userProgram.view computer memory
            in
            { title = title
            , body = [ render userProgram.atlases computer.screen shapes ]
            }

        subscriptions (Game memory _) =
            Sub.batch
                [ Sub.map Internal gameSubscriptions
                , Sub.map External <| userProgram.subscriptions memory
                ]
    in
    Browser.document
        { init = init
        , view = view
        , update = applicationUpdate userProgram.update
        , subscriptions = subscriptions
        }


{-| This is the message that is passed to your [`application`](#application).

A `Frame` comes approximately 16 times per second, whereas an `UserMsg` comes when needed,
either as a result of a `Cmd` or from a `Sub`. Read the [Elm Guide](https://guide.elm-lang.org/)
to find out more about those.

-}
type UserMsg msg
    = Frame
    | UserMsg msg


type ExternalMsg msg
    = Internal Msg
    | External msg


applicationUpdate : (UserMsg msg -> Computer -> memory -> ( memory, Cmd msg )) -> ExternalMsg msg -> Game memory -> ( Game memory, Cmd (ExternalMsg msg) )
applicationUpdate updateMemory msg (Game memory computer) =
    case msg of
        External emsg ->
            let
                ( newMemory, cmd ) =
                    updateMemory (UserMsg emsg) computer memory
            in
            ( Game newMemory computer, Cmd.map External cmd )

        Internal (Tick time) ->
            let
                ( newMemory, cmd ) =
                    updateMemory Frame computer memory

                newGame =
                    Game newMemory <|
                        if computer.mouse.click then
                            { computer | time = Time time, mouse = mouseClick False computer.mouse }

                        else
                            { computer | time = Time time }
            in
            ( newGame, Cmd.map External cmd )

        Internal (GotViewport { viewport }) ->
            ( Game memory { computer | screen = toScreen viewport.width viewport.height }, Cmd.none )

        Internal (Resized w h) ->
            ( Game memory { computer | screen = toScreen (toFloat w) (toFloat h) }, Cmd.none )

        Internal (KeyChanged isDown key) ->
            ( Game memory { computer | keyboard = updateKeyboard isDown key computer.keyboard }, Cmd.none )

        Internal (MouseMove pageX pageY) ->
            let
                x =
                    computer.screen.left + pageX

                y =
                    computer.screen.top - pageY
            in
            ( Game memory { computer | mouse = mouseMove x y computer.mouse }, Cmd.none )

        Internal MouseClick ->
            ( Game memory { computer | mouse = mouseClick True computer.mouse }, Cmd.none )

        Internal (MouseButton isDown) ->
            ( Game memory { computer | mouse = mouseDown isDown computer.mouse }, Cmd.none )



-- SHAPES


{-| Shapes help you make a `picture`, `animation`, or `game`.

Read on to see examples of [`circle`](#circle), [`rectangle`](#rectangle),
[`words`](#words), [`image`](#image), and many more!

-}
type Shape
    = Shape
        Number
        -- x
        Number
        -- y
        Number
        -- angle
        Number
        -- scale
        Number
        -- alpha
        Bool
        -- flipped
        Form


type Form
    = Circle Color Number
    | Oval Color Number Number
    | Rectangle Color Number Number
    | Ngon Color Int Number
    | Polygon Color (List ( Number, Number ))
    | Image Number Number String
    | Sprite
        Number
        -- w
        Number
        -- h
        String
        -- atlasName
        Int
        -- atlasX
        Int
      -- atlasY
    | Words Color String
    | Group (List Shape)


{-| Make circles:

    dot =
        circle red 10

    sun =
        circle yellow 300

You give a color and then the radius. So the higher the number, the larger
the circle.

-}
circle : Color -> Number -> Shape
circle color radius =
    Shape 0 0 0 1 1 False (Circle color radius)


{-| Make ovals:

    football =
        oval brown 200 100

You give the color, and then the width and height. So our `football` example
is 200 pixels wide and 100 pixels tall.

-}
oval : Color -> Number -> Number -> Shape
oval color width height =
    Shape 0 0 0 1 1 False (Oval color width height)


{-| Make squares. Here are two squares combined to look like an empty box:

    import Playground exposing (..)

    main =
        picture
            [ square purple 80
            , square white 60
            ]

The number you give is the dimension of each side. So that purple square would
be 80 pixels by 80 pixels.

-}
square : Color -> Number -> Shape
square color n =
    Shape 0 0 0 1 1 False (Rectangle color n n)


{-| Make rectangles. This example makes a red cross:

    import Playground exposing (..)

    main =
        picture
            [ rectangle red 20 60
            , rectangle red 60 20
            ]

You give the color, width, and then height. So the first shape is vertical
part of the cross, the thinner and taller part.

-}
rectangle : Color -> Number -> Number -> Shape
rectangle color width height =
    Shape 0 0 0 1 1 False (Rectangle color width height)


{-| Make triangles. So if you wanted to draw the Egyptian pyramids, you could
do a simple version like this:

    import Playground exposing (..)

    main =
        picture
            [ triangle darkYellow 200
            ]

The number is the "radius", so the distance from the center to each point of
the pyramid is `200`. Pretty big!

-}
triangle : Color -> Number -> Shape
triangle color radius =
    Shape 0 0 0 1 1 False (Ngon color 3 radius)


{-| Make pentagons:

    import Playground exposing (..)

    main =
        picture
            [ pentagon darkGrey 100
            ]

You give the color and then the radius. So the distance from the center to each
of the five points is 100 pixels.

-}
pentagon : Color -> Number -> Shape
pentagon color radius =
    Shape 0 0 0 1 1 False (Ngon color 5 radius)


{-| Make hexagons:

    import Playground exposing (..)

    main =
        picture
            [ hexagon lightYellow 50
            ]

The number is the radius, the distance from the center to each point.

If you made more hexagons, you could [`move`](#move) them around to make a
honeycomb pattern!

-}
hexagon : Color -> Number -> Shape
hexagon color radius =
    Shape 0 0 0 1 1 False (Ngon color 6 radius)


{-| Make octogons:

import Playground exposing (..)

main =
picture
[ octagon red 100
]

You give the color and radius, so each point of this stop sign is 100 pixels
from the center.

-}
octagon : Color -> Number -> Shape
octagon color radius =
    Shape 0 0 0 1 1 False (Ngon color 8 radius)


{-| Make any shape you want! Here is a very thin triangle:

    import Playground exposing (..)

    main =
        picture
            [ polygon [ ( -10, -20 ), ( 0, 100 ), ( 10, -20 ) ]
            ]

**Note:** If you [`rotate`](#rotate) a polygon, it will always rotate around
`(0,0)`. So it is best to build your shapes around that point, and then use
[`move`](#move) or [`group`](#group) so that rotation makes more sense.

-}
polygon : Color -> List ( Number, Number ) -> Shape
polygon color points =
    Shape 0 0 0 1 1 False (Polygon color points)


{-| Add some image from the internet:

    import Playground exposing (..)

    main =
        picture
            [ image 96 96 "https://elm-lang.org/assets/turtle.gif"
            ]

You provide the width, height, and then the URL of the image you want to show.

-}
image : Number -> Number -> String -> Shape
image w h src =
    Shape 0 0 0 1 1 False (Image w h src)


{-| This is a type for sprite sheets/texture atlases.

What's a sprite sheet? It's a big image containing all the animation frames for an object.

What's a texture atlas? It's a big image containing all the textures for different objects.

Technically they are one and the same, so they're represented with the same type.

You can use atlases with [`application`](#application),
adding them once (and so using less resources) and then referencing
them with [`sprite`](#sprite).

-}
type alias Atlas =
    { name : String
    , tileWidth : Int
    , tileHeight : Int
    , tileBorder : Int
    , width : Int
    , height : Int
    , href : String
    }


{-| Show a piece of an [`Atlas`](#Atlas).

The first parameter is the name you gave to the atlas when
adding it to your [`application`](#application), the second
and third parameters are the horizontal and vertical position
of the sprite (in terms of tiles: 0 is the top/left,
1 is the one immediately to the right/bottom, and so on...).

For example, if your animation is on the third row (which becomes 2,
because we count from zero), it has 7 frames, and you want to loop it
every 5 seconds you can write:

    sprite width height "atlasName" (spin (1.0 / 5.0) * 9 // 360) 2

-}
sprite : Number -> Number -> String -> Int -> Int -> Shape
sprite w h atlas ax ay =
    Shape 0 0 0 1 1 False (Sprite w h atlas ax ay)


{-| Show some words!

    import Playground exposing (..)

    main =
        picture
            [ words black "Hello! How are you?"
            ]

You can use [`scale`](#scale) to make the words bigger or smaller.

-}
words : Color -> String -> Shape
words color string =
    Shape 0 0 0 1 1 False (Words color string)


{-| Put shapes together so you can [`move`](#move) and [`rotate`](#rotate)
them as a group. Maybe you want to put a bunch of stars in the sky:

    import Playground exposing (..)

    main =
        picture
            [ star
                |> move 100 100
                |> rotate 5
            , star
                |> move -120 40
                |> rotate 20
            , star
                |> move 80 -150
                |> rotate 32
            , star
                |> move -90 -30
                |> rotate -16
            ]

    star =
        group
            [ triangle yellow 20
            , triangle yellow 20
                |> rotate 180
            ]

-}
group : List Shape -> Shape
group shapes =
    Shape 0 0 0 1 1 False (Group shapes)



-- TRANSFORMS


{-| Move a shape by some number of pixels:

    import Playground exposing (..)

    main =
        picture
            [ square red 100
                |> move -60 60
            , square yellow 100
                |> move 60 60
            , square green 100
                |> move 60 -60
            , square blue 100
                |> move -60 -60
            ]

-}
move : Number -> Number -> Shape -> Shape
move dx dy (Shape x y a s o l f) =
    Shape (x + dx) (y + dy) a s o l f


{-| Move a shape up by some number of pixels. So if you wanted to make a tree
you could move the leaves up above the trunk:

    import Playground exposing (..)

    main =
        picture
            [ rectangle brown 40 200
            , circle green 100
                |> moveUp 180
            ]

-}
moveUp : Number -> Shape -> Shape
moveUp =
    moveY


{-| Move a shape down by some number of pixels. So if you wanted to put the sky
above the ground, you could move the sky up and the ground down:

    import Playground exposing (..)

    main =
        picture
            [ rectangle lightBlue 200 100
                |> moveUp 50
            , rectangle lightGreen 200 100
                |> moveDown 50
            ]

-}
moveDown : Number -> Shape -> Shape
moveDown dy (Shape x y a s o l f) =
    Shape x (y - dy) a s o l f


{-| Move shapes to the left.

    import Playground exposing (..)

    main =
        picture
            [ circle yellow 10
                |> moveLeft 80
                |> moveUp 30
            ]

-}
moveLeft : Number -> Shape -> Shape
moveLeft dx (Shape x y a s o l f) =
    Shape (x - dx) y a s o l f


{-| Move shapes to the right.

    import Playground exposing (..)

    main =
        picture
            [ square purple 20
                |> moveRight 80
                |> moveDown 100
            ]

-}
moveRight : Number -> Shape -> Shape
moveRight =
    moveX


{-| Move the `x` coordinate of a shape by some amount. Here is a square that
moves back and forth:

    import Playground exposing (..)

    main =
        animation view

    view time =
        [ square purple 20
            |> moveX (wave 4 -200 200 time)
        ]

Using `moveX` feels a bit nicer here because the movement may be positive or negative.

-}
moveX : Number -> Shape -> Shape
moveX dx (Shape x y a s o l f) =
    Shape (x + dx) y a s o l f


{-| Move the `y` coordinate of a shape by some amount. Maybe you want to make
grass along the bottom of the screen:

    import Playground exposing (..)

    main =
        game view update 0

    update computer memory =
        memory

    view computer count =
        [ rectangle green computer.screen.width 100
            |> moveY computer.screen.bottom
        ]

Using `moveY` feels a bit nicer when setting things relative to the bottom or
top of the screen, since the values are negative sometimes.

-}
moveY : Number -> Shape -> Shape
moveY dy (Shape x y a s o l f) =
    Shape x (y + dy) a s o l f


{-| Make a shape bigger or smaller. So if you wanted some [`words`](#words) to
be larger, you could say:

    import Playground exposing (..)

    main =
        picture
            [ words black "Hello, nice to see you!"
                |> scale 3
            ]

-}
scale : Number -> Shape -> Shape
scale ns (Shape x y a s o l f) =
    Shape x y a (s * ns) o l f


{-| Rotate shapes in degrees.

    import Playground exposing (..)

    main =
        picture
            [ words black "These words are tilted!"
                |> rotate 10
            ]

The degrees go **counter-clockwise** to match the direction of the
[unit circle](https://en.wikipedia.org/wiki/Unit_circle).

-}
rotate : Number -> Shape -> Shape
rotate da (Shape x y a s o l f) =
    Shape x y (a + da) s o l f


{-| Flips shapes horizontally.

    import Playground exposing (..)

    main =
        picture
            [ words black "These words are right to left!"
                |> flipHorizontally
            ]

-}
flipHorizontally : Shape -> Shape
flipHorizontally (Shape x y a s o l f) =
    Shape x y a s o (not l) f


{-| Flips shapes vertically.

    import Playground exposing (..)

    main =
        picture
            [ words black "These words are upside down!"
                |> flipVertically
            ]

-}
flipVertically : Shape -> Shape
flipVertically (Shape x y a s o l f) =
    Shape x y (a + 180) s o (not l) f


{-| Fade a shape. This lets you make shapes see-through or even completely
invisible. Here is a shape that fades in and out:

    import Playground exposing (..)

    main =
        animation view

    view time =
        [ square orange 30
        , square blue 200
            |> fade (zigzag 0 1 3 time)
        ]

The number has to be between `0` and `1`, where `0` is totally transparent
and `1` is completely solid.

-}
fade : Number -> Shape -> Shape
fade o (Shape x y a s _ l f) =
    Shape x y a s o l f



-- COLOR


{-| Represents a color.

The colors below, like `red` and `green`, come from the [Tango palette][tango].
It provides a bunch of aesthetically reasonable colors. Each color comes with a
light and dark version, so you always get a set like `lightYellow`, `yellow`,
and `darkYellow`.

[tango]: https://en.wikipedia.org/wiki/Tango_Desktop_Project

-}
type Color
    = Hex String
    | Rgb Int Int Int


{-| -}
lightYellow : Color
lightYellow =
    Hex "#fce94f"


{-| -}
yellow : Color
yellow =
    Hex "#edd400"


{-| -}
darkYellow : Color
darkYellow =
    Hex "#c4a000"


{-| -}
lightOrange : Color
lightOrange =
    Hex "#fcaf3e"


{-| -}
orange : Color
orange =
    Hex "#f57900"


{-| -}
darkOrange : Color
darkOrange =
    Hex "#ce5c00"


{-| -}
lightBrown : Color
lightBrown =
    Hex "#e9b96e"


{-| -}
brown : Color
brown =
    Hex "#c17d11"


{-| -}
darkBrown : Color
darkBrown =
    Hex "#8f5902"


{-| -}
lightGreen : Color
lightGreen =
    Hex "#8ae234"


{-| -}
green : Color
green =
    Hex "#73d216"


{-| -}
darkGreen : Color
darkGreen =
    Hex "#4e9a06"


{-| -}
lightBlue : Color
lightBlue =
    Hex "#729fcf"


{-| -}
blue : Color
blue =
    Hex "#3465a4"


{-| -}
darkBlue : Color
darkBlue =
    Hex "#204a87"


{-| -}
lightPurple : Color
lightPurple =
    Hex "#ad7fa8"


{-| -}
purple : Color
purple =
    Hex "#75507b"


{-| -}
darkPurple : Color
darkPurple =
    Hex "#5c3566"


{-| -}
lightRed : Color
lightRed =
    Hex "#ef2929"


{-| -}
red : Color
red =
    Hex "#cc0000"


{-| -}
darkRed : Color
darkRed =
    Hex "#a40000"


{-| -}
lightGrey : Color
lightGrey =
    Hex "#eeeeec"


{-| -}
grey : Color
grey =
    Hex "#d3d7cf"


{-| -}
darkGrey : Color
darkGrey =
    Hex "#babdb6"


{-| -}
lightCharcoal : Color
lightCharcoal =
    Hex "#888a85"


{-| -}
charcoal : Color
charcoal =
    Hex "#555753"


{-| -}
darkCharcoal : Color
darkCharcoal =
    Hex "#2e3436"


{-| -}
white : Color
white =
    Hex "#FFFFFF"


{-| -}
black : Color
black =
    Hex "#000000"



-- ALTERNATE SPELLING GREYS


{-| -}
lightGray : Color
lightGray =
    Hex "#eeeeec"


{-| -}
gray : Color
gray =
    Hex "#d3d7cf"


{-| -}
darkGray : Color
darkGray =
    Hex "#babdb6"



-- CUSTOM COLORS


{-| RGB stands for Red-Green-Blue. With these three parts, you can create any
color you want. For example:

    brightBlue =
        rgb 18 147 216

    brightGreen =
        rgb 119 244 8

    brightPurple =
        rgb 94 28 221

Each number needs to be between 0 and 255.

It can be hard to figure out what numbers to pick, so try using a color picker
like [paletton] to find colors that look nice together. Once you find nice
colors, click on the color previews to get their RGB values.

[paletton]: http://paletton.com/

-}
rgb : Number -> Number -> Number -> Color
rgb r g b =
    Rgb (colorClamp r) (colorClamp g) (colorClamp b)


colorClamp : Number -> Int
colorClamp number =
    clamp 0 255 (round number)



-- RENDER


render : List Atlas -> Screen -> List Shape -> Html.Html msg
render atlases screen shapes =
    let
        w =
            String.fromFloat screen.width

        h =
            String.fromFloat screen.height

        x =
            String.fromFloat screen.left

        y =
            String.fromFloat screen.bottom

        atlasesDict =
            atlases
                |> List.map (\atlas -> ( atlas.name, { atlas = atlas, used = [] } ))
                |> Dict.fromList

        atlasesWithUsed : List { atlas : Atlas, used : List ( Int, Int ) }
        atlasesWithUsed =
            shapes
                |> List.concatMap extractSymbols
                |> List.foldl
                    (\{ atlasName, symbol } ->
                        Dict.update atlasName
                            (Maybe.map <| \atlas -> { atlas | used = symbol :: atlas.used })
                    )
                    atlasesDict
                |> Dict.values
                |> List.map (\atlas -> { atlas | used = atlas.used |> Set.fromList |> Set.toList })
    in
    svg
        [ viewBox (x ++ " " ++ y ++ " " ++ w ++ " " ++ h)
        , H.style "position" "fixed"
        , H.style "top" "0"
        , H.style "left" "0"
        , width "100%"
        , height "100%"
        ]
        (renderAtlases atlasesWithUsed
            :: List.map renderShape shapes
        )


extractSymbols : Shape -> List { atlasName : String, symbol : ( Int, Int ) }
extractSymbols (Shape _ _ _ _ _ _ form) =
    case form of
        Sprite _ _ atlasName x y ->
            [ { atlasName = atlasName
              , symbol = ( x, y )
              }
            ]

        Group ss ->
            List.concatMap extractSymbols ss

        Rectangle _ _ _ ->
            []

        Circle _ _ ->
            []

        Ngon _ _ _ ->
            []

        Oval _ _ _ ->
            []

        Image _ _ _ ->
            []

        Words _ _ ->
            []

        Polygon _ _ ->
            []


renderAtlases : List { atlas : Atlas, used : List ( Int, Int ) } -> Svg msg
renderAtlases ats =
    let
        symbols atlas used =
            let
                viewSymbol ( ax, ay ) =
                    let
                        sid =
                            atlas.name ++ "-" ++ String.fromInt ax ++ "-" ++ String.fromInt ay

                        vb =
                            String.join " " <|
                                List.map String.fromInt
                                    [ atlas.tileBorder + ax * (atlas.tileBorder + atlas.tileWidth)
                                    , atlas.tileBorder + ay * (atlas.tileBorder + atlas.tileHeight)
                                    , atlas.tileWidth
                                    , atlas.tileHeight
                                    ]
                    in
                    symbol
                        [ id sid
                        , viewBox vb
                        , width <| String.fromInt atlas.tileWidth
                        , height <| String.fromInt atlas.tileHeight
                        ]
                        [ use [ H.attribute "href" <| "#" ++ atlas.name ] []
                        ]
            in
            List.map viewSymbol used
    in
    defs []
        (List.concatMap
            (\{ atlas, used } ->
                symbol
                    [ id atlas.name
                    , width <| String.fromInt atlas.width
                    , height <| String.fromInt atlas.height
                    , viewBox <| "0 0 " ++ String.fromInt atlas.width ++ " " ++ String.fromInt atlas.height
                    ]
                    [ Svg.image
                        [ H.attribute "href" atlas.href
                        , width <| String.fromInt atlas.width
                        , height <| String.fromInt atlas.height
                        ]
                        []
                    ]
                    :: symbols atlas used
            )
            ats
        )



-- TODO try adding Svg.Lazy to renderShape
--


renderShape : Shape -> Svg msg
renderShape (Shape x y angle s alpha flipped form) =
    case form of
        Circle color radius ->
            renderCircle color radius x y angle s flipped alpha

        Oval color width height ->
            renderOval color width height x y angle s flipped alpha

        Rectangle color width height ->
            renderRectangle color width height x y angle s flipped alpha

        Ngon color n radius ->
            renderNgon color n radius x y angle s flipped alpha

        Polygon color points ->
            renderPolygon color points x y angle s flipped alpha

        Image width height src ->
            renderImage width height src x y angle s flipped alpha

        Sprite width height atlas ax ay ->
            renderSprite width height atlas ax ay x y angle s flipped alpha

        Words color string ->
            renderWords color string x y angle s flipped alpha

        Group shapes ->
            let
                transformString =
                    renderTransform x y angle s flipped
            in
            if String.isEmpty transformString then
                g (renderAlpha alpha)
                    (List.map renderShape shapes)

            else
                g (transform transformString :: renderAlpha alpha)
                    (List.map renderShape shapes)


shapeCommonAttrs : Color -> Number -> Number -> Number -> Number -> Bool -> Number -> List (Attribute msg)
shapeCommonAttrs color x y angle s flipped alpha =
    let
        transformString =
            renderTransform x y angle s flipped
    in
    if String.isEmpty transformString then
        fill (renderColor color)
            :: renderAlpha alpha

    else
        fill (renderColor color)
            :: transform transformString
            :: renderAlpha alpha



-- RENDER CIRCLE AND OVAL


renderCircle : Color -> Number -> Number -> Number -> Number -> Number -> Bool -> Number -> Svg msg
renderCircle color radius x y angle s flipped alpha =
    Svg.circle
        (r (String.fromFloat radius)
            :: shapeCommonAttrs color x y angle s flipped alpha
        )
        []


renderOval : Color -> Number -> Number -> Number -> Number -> Number -> Number -> Bool -> Number -> Svg msg
renderOval color width height x y angle s flipped alpha =
    ellipse
        (rx (String.fromFloat (width / 2))
            :: ry (String.fromFloat (height / 2))
            :: shapeCommonAttrs color x y angle s flipped alpha
        )
        []



-- RENDER RECTANGLE AND IMAGE


renderRectangle : Color -> Number -> Number -> Number -> Number -> Number -> Number -> Bool -> Number -> Svg msg
renderRectangle color w h x y angle s flipped alpha =
    rect
        (width (String.fromFloat w)
            :: height (String.fromFloat h)
            :: fill (renderColor color)
            :: transform (renderRectTransform w h x y angle s flipped)
            :: renderAlpha alpha
        )
        []


renderRectTransform : Number -> Number -> Number -> Number -> Number -> Number -> Bool -> String
renderRectTransform width height x y angle s flipped =
    renderTransform x y angle s flipped
        ++ " translate("
        ++ String.fromFloat (-width / 2)
        ++ ","
        ++ String.fromFloat (-height / 2)
        ++ ")"


renderImage : Number -> Number -> String -> Number -> Number -> Number -> Number -> Bool -> Number -> Svg msg
renderImage w h src x y angle s flipped alpha =
    Svg.image
        (xlinkHref src
            :: width (String.fromFloat w)
            :: height (String.fromFloat h)
            :: transform (renderRectTransform w h x y angle s flipped)
            :: renderAlpha alpha
        )
        []


renderSprite : Number -> Number -> String -> Int -> Int -> Number -> Number -> Number -> Number -> Bool -> Number -> Svg msg
renderSprite w h atlas ax ay x y angle s flipped alpha =
    Svg.use
        (H.attribute "href" ("#" ++ atlas ++ "-" ++ String.fromInt ax ++ "-" ++ String.fromInt ay)
            :: width (String.fromFloat w)
            :: height (String.fromFloat h)
            :: transform (renderRectTransform w h x y angle s flipped)
            :: renderAlpha alpha
        )
        []



-- RENDER NGON


renderNgon : Color -> Int -> Number -> Number -> Number -> Number -> Number -> Bool -> Number -> Svg msg
renderNgon color n radius x y angle s flipped alpha =
    Svg.polygon
        (points (toNgonPoints 0 n radius "")
            :: fill (renderColor color)
            :: transform (renderTransform x y angle s flipped)
            :: renderAlpha alpha
        )
        []


toNgonPoints : Int -> Int -> Float -> String -> String
toNgonPoints i n radius string =
    if i == n then
        string

    else
        let
            a =
                turns (toFloat i / toFloat n - 0.25)

            x =
                radius * cos a

            y =
                radius * sin a
        in
        toNgonPoints (i + 1) n radius (string ++ String.fromFloat x ++ "," ++ String.fromFloat y ++ " ")



-- RENDER POLYGON


renderPolygon : Color -> List ( Number, Number ) -> Number -> Number -> Number -> Number -> Bool -> Number -> Svg msg
renderPolygon color coordinates x y angle s flipped alpha =
    Svg.polygon
        (points (List.foldl addPoint "" coordinates)
            :: fill (renderColor color)
            :: transform (renderTransform x y angle s flipped)
            :: renderAlpha alpha
        )
        []


addPoint : ( Float, Float ) -> String -> String
addPoint ( x, y ) str =
    str ++ String.fromFloat x ++ "," ++ String.fromFloat y ++ " "



-- RENDER WORDS


renderWords : Color -> String -> Number -> Number -> Number -> Number -> Bool -> Number -> Svg msg
renderWords color string x y angle s flipped alpha =
    text_
        (textAnchor "middle"
            :: dominantBaseline "central"
            :: fill (renderColor color)
            :: transform (renderTransform x y angle s flipped)
            :: renderAlpha alpha
        )
        [ text string
        ]



-- RENDER COLOR


renderColor : Color -> String
renderColor color =
    case color of
        Hex str ->
            str

        Rgb r g b ->
            "rgb(" ++ String.fromInt r ++ "," ++ String.fromInt g ++ "," ++ String.fromInt b ++ ")"



-- RENDER ALPHA


renderAlpha : Number -> List (Svg.Attribute msg)
renderAlpha alpha =
    if alpha == 1 then
        []

    else
        [ opacity (String.fromFloat (clamp 0 1 alpha)) ]



-- RENDER TRANFORMS


renderTransform : Number -> Number -> Number -> Number -> Bool -> String
renderTransform x y a s l =
    let
        translation =
            if x == 0 && y == 0 then
                ""

            else
                "translate(" ++ String.fromFloat x ++ "," ++ String.fromFloat -y ++ ") "

        rotation =
            if a == 0 then
                ""

            else
                "rotate(" ++ String.fromFloat -a ++ ")"

        scaling =
            if l then
                "scale(-" ++ String.fromFloat s ++ "," ++ String.fromFloat s ++ ")"

            else if s == 1 then
                ""

            else
                "scale(" ++ String.fromFloat s ++ ")"
    in
    String.join " " <| List.filter (not << String.isEmpty) [ translation, rotation, scaling ]
