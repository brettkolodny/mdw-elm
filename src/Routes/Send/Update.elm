port module Routes.Send.Update exposing (..)

import Routes.Send.Model as Send
import Session.Model exposing (Account)



-- PORTS


port sendMessage : PortMessage -> Cmd msg


type alias PortData =
    { from : String
    , to : String
    , amount : Float
    }


type alias PortMessage =
    { tag : String
    , data : PortData
    }


port transactionPreview : (Int -> msg) -> Sub msg



-- MSG


type Msg
    = ToAddressUpdated String
    | ToggleToAddressSelection
    | ToAddressSelected String
    | FromAddressSelected Account
    | ToggleFromAddressSelection
    | SendAmountUpdated String
    | TransactionPreview Int



-- UPDATE


update : Msg -> Send.Model -> ( Send.Model, Cmd a )
update msg model =
    case msg of
        ToAddressUpdated address ->
            ( { model | toAddress = address }, Cmd.none )

        ToggleToAddressSelection ->
            ( { model | showToAddressSelection = not model.showToAddressSelection }, Cmd.none )

        ToAddressSelected address ->
            ( { model | toAddress = address, showToAddressSelection = not model.showToAddressSelection }, Cmd.none )

        FromAddressSelected account ->
            ( { model | fromAccount = Just account, showFromAddressSelection = not model.showFromAddressSelection }, Cmd.none )

        ToggleFromAddressSelection ->
            ( { model | showFromAddressSelection = not model.showFromAddressSelection }, Cmd.none )

        SendAmountUpdated amount ->
            let
                sendAmount =
                    Maybe.withDefault 0.0 model.sendAmount

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
