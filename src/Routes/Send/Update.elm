port module Routes.Send.Update exposing (..)

import Routes.Send.Model as Send
import Session.Model exposing (Account, Network(..))



-- PORTS


port sendMessage : PortMessage -> Cmd msg


type alias PortData =
    { from : String
    , to : String
    , amount : Int
    }


type alias PortMessage =
    { tag : String
    , data : PortData
    }


port transactionPreview : (Int -> msg) -> Sub msg


port sendTransactionDeclined : (() -> msg) -> Sub msg


port sendTransactionSuccess : (() -> msg) -> Sub msg



-- MSG


type Msg
    = ToAddressUpdated String
    | ToggleToAddressSelection
    | ToAddressSelected String
    | FromAddressSelected Account
    | ToggleFromAddressSelection
    | SendAmountUpdated String Network
    | TransactionPreview Int
    | ToggleVerifyTransaction
    | SendTokens Network
    | SendTransactionDeclined ()
    | SendTransactionSuccess ()
    | SendAnother



-- UPDATE


update : Msg -> Send.Model -> ( Send.Model, Cmd a )
update msg model =
    case msg of
        ToAddressUpdated address ->
            ( { model | toAddress = address }, Cmd.none )

        ToggleToAddressSelection ->
            ( { model | showToAddressSelection = not model.showToAddressSelection, showFromAddressSelection = False }, Cmd.none )

        ToAddressSelected address ->
            ( { model | toAddress = address, showToAddressSelection = not model.showToAddressSelection }, Cmd.none )

        FromAddressSelected account ->
            ( { model | fromAccount = Just account, showFromAddressSelection = not model.showFromAddressSelection }, Cmd.none )

        ToggleFromAddressSelection ->
            ( { model | showFromAddressSelection = not model.showFromAddressSelection, showToAddressSelection = False }, Cmd.none )

        SendAmountUpdated amount network ->
            let
                decimals =
                    case network of
                        Polkadot ->
                            10

                        Kusama ->
                            12

                sendAmount =
                    round (Maybe.withDefault 0.0 model.sendAmount * (10 ^ decimals))

                cmd =
                    case ( model.fromAccount, model.toAddress ) of
                        ( Just acc, to ) ->
                            if to /= "" then
                                sendMessage
                                    { tag = "send-preview"
                                    , data = { from = acc.address, to = to, amount = sendAmount }
                                    }

                            else
                                Cmd.none

                        _ ->
                            Cmd.none
            in
            ( { model | sendAmount = String.toFloat amount }, cmd )

        TransactionPreview amount ->
            ( { model | transactionPreview = amount }, Cmd.none )

        ToggleVerifyTransaction ->
            ( { model | verifyTransaction = not model.verifyTransaction }, Cmd.none )

        SendTokens network ->
            let
                decimals =
                    case network of
                        Polkadot ->
                            10

                        Kusama ->
                            12

                sendAmount =
                    round (Maybe.withDefault 0.0 model.sendAmount * (10 ^ decimals))

                cmd =
                    case ( model.fromAccount, model.toAddress ) of
                        ( Just acc, to ) ->
                            if to /= "" then
                                sendMessage
                                    { tag = "send-tokens"
                                    , data = { from = acc.address, to = to, amount = sendAmount }
                                    }

                            else
                                Cmd.none

                        _ ->
                            Cmd.none
            in
            ( { model | confirming = True }, cmd )

        SendTransactionDeclined _ ->
            ( { model | confirming = False }, Cmd.none )

        SendTransactionSuccess _ ->
            ( { model | confirming = False, confirmed = True }, Cmd.none )

        SendAnother ->
            ( Send.model, Cmd.none )
