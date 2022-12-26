module Routes.Send.Update exposing (..)

import Routes.Send.Model as Send
import Session.Model exposing (Account)


type Msg
    = ToAddressUpdated String
    | ToggleToAddressSelection
    | ToAddressSelected String
    | FromAddressSelected Account
    | ToggleFromAddressSelection
    | SendAmountUpdated String


update : Msg -> Send.Model -> Send.Model
update msg model =
    case msg of
        ToAddressUpdated address ->
            { model | toAddress = address }

        ToggleToAddressSelection ->
            { model | showToAddressSelection = not model.showToAddressSelection }

        ToAddressSelected address ->
            { model | toAddress = address, showToAddressSelection = not model.showToAddressSelection }

        FromAddressSelected account ->
            { model | fromAccount = Just account, showFromAddressSelection = not model.showFromAddressSelection }

        ToggleFromAddressSelection ->
            { model | showFromAddressSelection = not model.showFromAddressSelection }

        SendAmountUpdated amount ->
            { model | sendAmount = String.toFloat amount }
