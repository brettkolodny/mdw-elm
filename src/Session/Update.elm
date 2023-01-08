port module Session.Update exposing (..)

import Session.Model exposing (Account, Model, Network(..))


port updateAccounts : (List Account -> msg) -> Sub msg


type alias PortData =
    { network : Maybe String, extension : Maybe String }


type alias PortMessage =
    { tag : String
    , data : PortData
    }


port sessionMessage : PortMessage -> Cmd msg


type Msg
    = ToggleShowNetworks
    | SwitchNetwork Network
    | ConnectExtension String
    | ToggleShowExtensions
    | UpdateAccounts (List Account)


update : Msg -> Model -> ( Model, Cmd a )
update msg model =
    case msg of
        UpdateAccounts accounts ->
            ( { model | accounts = accounts }, Cmd.none )

        ToggleShowNetworks ->
            let
                oldNetwork =
                    model.network

                newNetwork =
                    { oldNetwork | showNetworks = not oldNetwork.showNetworks }
            in
            ( { model | network = newNetwork }, Cmd.none )

        SwitchNetwork network ->
            let
                oldNetwork =
                    model.network

                newNetwork =
                    { oldNetwork | currentNetwork = network, showNetworks = not oldNetwork.showNetworks }

                networkString =
                    case network of
                        Polkadot ->
                            "Polkadot"

                        Kusama ->
                            "Kusama"
            in
            ( { model | network = newNetwork, accounts = [] }
            , sessionMessage
                { tag = "network-update"
                , data = { network = Just networkString, extension = model.extension.currentExtension }
                }
            )

        ConnectExtension extensionName ->
            let
                oldExtensionState =
                    model.extension

                newExtensionState =
                    if extensionName /= Maybe.withDefault "" model.extension.currentExtension then
                        { oldExtensionState | currentExtension = Just extensionName, showExtensions = False }

                    else if extensionName == "disconnect" then
                        { oldExtensionState | currentExtension = Nothing, showExtensions = False }

                    else
                        { oldExtensionState | showExtensions = False }
            in
            if extensionName == "disconnect" then
                ( { model | extension = newExtensionState, accounts = [] }, Cmd.none )

            else if extensionName /= Maybe.withDefault "" model.extension.currentExtension then
                ( { model | extension = newExtensionState }
                , sessionMessage { tag = "extension-connect", data = { network = Nothing, extension = Just extensionName } }
                )

            else
                ( { model | extension = newExtensionState }, Cmd.none )

        ToggleShowExtensions ->
            let
                oldExtensionState =
                    model.extension

                newExtensionState =
                    { oldExtensionState | showExtensions = not oldExtensionState.showExtensions }
            in
            ( { model | extension = newExtensionState }, Cmd.none )
