module Session.Update exposing (..)

import Session.Model exposing (Account, Model, Network)


type Msg
    = ToggleAccountInfo String
    | ToggleShowNetworks
    | SwitchNetwork Network
    | ConnectExtension String
    | ToggleShowExtensions


update : Msg -> Model -> Model
update msg model =
    case msg of
        ToggleAccountInfo address ->
            { model | accounts = List.map (toggleAccount address) model.accounts }

        ToggleShowNetworks ->
            let
                oldNetwork =
                    model.network

                newNetwork =
                    { oldNetwork | showNetworks = not oldNetwork.showNetworks }
            in
            { model | network = newNetwork }

        SwitchNetwork network ->
            let
                oldNetwork =
                    model.network

                newNetwork =
                    { oldNetwork | currentNetwork = network, showNetworks = not oldNetwork.showNetworks }

                accounts =
                    List.map (\account -> { account | balance = Nothing }) model.accounts
            in
            { model | network = newNetwork, accounts = accounts }

        ConnectExtension extensionName ->
            let
                oldExtensionState =
                    model.extension

                netExtensionState =
                    { oldExtensionState | currentExtension = Just extensionName, showExtensions = False }
            in
            if extensionName /= Maybe.withDefault "" model.extension.currentExtension then
                { model | extension = netExtensionState }

            else
                model

        ToggleShowExtensions ->
            let
                oldExtensionState =
                    model.extension

                newExtensionState =
                    { oldExtensionState | showExtensions = not oldExtensionState.showExtensions }
            in
            { model | extension = newExtensionState }


toggleAccount : String -> Account -> Account
toggleAccount address account =
    if address == account.address then
        { account | show = not account.show }

    else
        account
