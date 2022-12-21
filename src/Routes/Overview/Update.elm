module Routes.Overview.Update exposing (..)

import Routes.Overview.Model as Overview


type Msg
    = ToggleShow String


update : Msg -> Overview.Model -> Overview.Model
update msg model =
    case msg of
        ToggleShow address ->
            let
                toggleAccount =
                    if List.member address model then
                        List.filter (\a -> a /= address) model

                    else
                        address :: model
            in
            toggleAccount
