port module Main exposing (main)

import Accounts exposing (accounts)
import Browser
import Extension exposing (selectExtension)
import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Http
import Json.Decode exposing (Decoder, field, float, map, map2)
import Model exposing (Model, Route(..))
import Msg exposing (Msg(..))
import NavBar exposing (navBar)
import Network exposing (networkSelect)
import Session.Model exposing (Account, Network(..), Prices, Usd)
import Session.Update as SessionUpdate


main : Program (List String) Model Msg
main =
    Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }



-- PORTS


port updateAccounts : (List Account -> msg) -> Sub msg


type alias PortData =
    { network : Maybe String, extension : Maybe String }


type alias PortMessage =
    { tag : String
    , data : PortData
    }


port sendMessage : PortMessage -> Cmd msg


init : List String -> ( Model, Cmd Msg )
init extensions =
    ( { session =
            { accounts = []
            , network = { currentNetwork = Polkadot, showNetworks = False }
            , prices = Nothing
            , extension =
                { extensions = extensions
                , currentExtension = Nothing
                , showExtensions = False
                }
            }
      , route = AccountsRoute
      }
    , Http.get
        { url = "https://api.coingecko.com/api/v3/simple/price?ids=polkadot%2Ckusama&vs_currencies=usd"
        , expect = Http.expectJson GotPrices pricesDecoder
        }
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SessionMsg msg_ ->
            let
                session =
                    SessionUpdate.update msg_ model.session
            in
            ( { model | session = session }, Cmd.none )

        UpdateAccounts accounts ->
            let
                oldSession =
                    model.session

                newSession =
                    { oldSession | accounts = accounts }
            in
            ( { model | session = newSession }, Cmd.none )

        SwitchNetwork network ->
            let
                oldNetwork =
                    model.session.network

                newNetwork =
                    { oldNetwork | currentNetwork = network, showNetworks = not oldNetwork.showNetworks }

                networkString =
                    case network of
                        Polkadot ->
                            "Polkadot"

                        Kusama ->
                            "Kusama"

                accounts =
                    List.map (\account -> { account | balance = Nothing }) model.session.accounts

                oldSession =
                    model.session

                newSession =
                    { oldSession | network = newNetwork, accounts = accounts }
            in
            ( { model | session = newSession }
            , sendMessage
                { tag = "network-update"
                , data = { network = Just networkString, extension = model.session.extension.currentExtension }
                }
            )

        ConnectExtension extensionName ->
            let
                oldExtensionState =
                    model.session.extension

                netExtensionState =
                    { oldExtensionState | currentExtension = Just extensionName, showExtensions = False }

                oldSession =
                    model.session

                newSession =
                    { oldSession | extension = netExtensionState }
            in
            if extensionName /= Maybe.withDefault "" model.session.extension.currentExtension then
                ( { model | session = newSession }
                , sendMessage { tag = "extension-connect", data = { network = Nothing, extension = Just extensionName } }
                )

            else
                ( model, Cmd.none )

        GotPrices result ->
            case result of
                Ok prices ->
                    let
                        oldSession =
                            model.session

                        newSession =
                            { oldSession | prices = Just prices }
                    in
                    ( { model | session = newSession }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    let
        page =
            case model.route of
                AccountsRoute ->
                    accounts

                SendRoute _ ->
                    accounts

                NotFoundRoute ->
                    accounts
    in
    div [ class "flex flex-col justify-center items-center" ]
        [ div [ class "absolute flex flex-row justify-center items-center h-20 w-screen top-0 left-0 " ]
            [ div [ class "flex flex-row justify-end w-full max-w-5xl gap-24 mt-4" ]
                [ networkSelect model.session.network
                , selectExtension model.session
                ]
            ]
        , div [ class "flex flex-row w-full" ] [ navBar model, page model.session ]
        ]


pricesDecoder : Decoder Prices
pricesDecoder =
    let
        decodeUsd =
            map Usd (field "usd" float)
    in
    map2 Prices
        (field "polkadot" decodeUsd)
        (field "kusama" decodeUsd)


subscriptions : Model -> Sub Msg
subscriptions _ =
    updateAccounts UpdateAccounts
