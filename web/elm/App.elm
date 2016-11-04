port module App exposing (..)

import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Html.App

import Components.CustomerList as CustomerList

type alias Model =
  { customerListModel: CustomerList.Model }

init : (Model, Cmd Msg)
init =
  ( { customerListModel = CustomerList.initialModel }, Cmd.none )

type Msg
  = CustomerListMsg CustomerList.Msg
  | JsMsg (List String)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    CustomerListMsg customerListMsg ->
      let (updatedModel, cmd) = CustomerList.update customerListMsg model.customerListModel
      in ( { model | customerListModel = updatedModel }, Cmd.map CustomerListMsg cmd )
    JsMsg ["CustomerList.Fetch"] ->
      let (updatedModel, cmd) = CustomerList.update CustomerList.Fetch model.customerListModel
      in ( { model | customerListModel = updatedModel }, Cmd.map CustomerListMsg cmd )
    JsMsg ["CustomerList.Search", query] ->
      let (updatedModel, cmd) = CustomerList.update (CustomerList.Search query) model.customerListModel
      in ( { model | customerListModel = updatedModel }, Cmd.map CustomerListMsg cmd )
    JsMsg _ ->
      (model, Cmd.none)

customerListView : Model -> Html Msg
customerListView model =
  Html.App.map CustomerListMsg (CustomerList.view model.customerListModel)

pageView : Model -> Html Msg
pageView model =
  customerListView model

view : Model -> Html Msg
view model =
  div [ class "elm-app" ] [ pageView model ]

subscriptions : Model -> Sub Msg
subscriptions model =
  jsEvents JsMsg

-- port for listening for events from JavaScript
port jsEvents : (List String -> msg) -> Sub msg

main : Program Never
main =
  Html.App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }
