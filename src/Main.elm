module Main exposing (main)

import Browser
import Extension exposing (selectExtension)
import Html exposing (Html, a, div, img)
import Html.Attributes exposing (class, src, href)
import Http
import Json.Decode exposing (Decoder, field, float, map, map2)
import Model exposing (Model, Page(..), Route(..))
import Msg exposing (Msg(..))
import NavBar exposing (navBar)
import Network exposing (networkSelect)
import Routes.Overview.Model as OverviewModel
import Routes.Overview.Update as OverviewUpdate
import Routes.Overview.View exposing (accounts)
import Routes.Send.Update as SendUpdate
import Routes.Send.View exposing (send)
import Session.Model exposing (Network(..), Prices, Usd)
import Session.Update as SessionUpdate
import VitePluginHelper


main : Program (List String) Model Msg
main =
    Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }


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
      , page =
            Overview OverviewModel.model
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
                ( session, cmd ) =
                    SessionUpdate.update msg_ model.session
            in
            ( { model | session = session }, cmd )

        OverviewMsg msg_ ->
            let
                page =
                    case model.page of
                        Overview m ->
                            Overview (OverviewUpdate.update msg_ m)

                        _ ->
                            model.page
            in
            ( { model | page = page }, Cmd.none )

        SendMsg msg_ ->
            let
                ( page, cmd ) =
                    case model.page of
                        Send m ->
                            let
                                ( page_, cmd_ ) =
                                    SendUpdate.update msg_ m
                            in
                            ( Send page_, cmd_ )

                        _ ->
                            ( model.page, Cmd.none )
            in
            ( { model | page = page }, cmd )

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

        ChangePage page ->
            ( { model | page = page }, Cmd.none )


view : Model -> Html Msg
view model =
    let
        page =
            case model.page of
                Overview m ->
                    accounts model.session m

                Send m ->
                    send model.session m
    in
    div [ class "flex flex-col justify-center items-center" ]
        [ div [ class "absolute flex flex-row justify-center items-center h-24 w-screen top-0 left-0 " ]
            [ div [ class "flex flex-row justify-between w-full px-16 gap-6 mt-4" ]
                [ a [ href "/" ] [ img [ src <| VitePluginHelper.asset "/src/assets/MyDotWallet.svg" ] [] ]
                , div [ class "flex flex-row gap-4" ]
                    [ networkSelect model.session.network
                    , selectExtension model.session
                    ]
                ]
            ]
        , div [ class "flex flex-row w-full" ] [ navBar model, page ]
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
    Sub.batch
        [ SessionUpdate.updateAccounts (SessionUpdate.UpdateAccounts >> SessionMsg)
        , SendUpdate.transactionPreview (SendUpdate.TransactionPreview >> SendMsg)
        , SendUpdate.sendTransactionDeclined (SendUpdate.SendTransactionDeclined >> SendMsg)
        , SendUpdate.sendTransactionSuccess (SendUpdate.SendTransactionSuccess >> SendMsg)
        ]
