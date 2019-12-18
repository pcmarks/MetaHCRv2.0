module InvestigationTypes exposing (..)

{-| Type support for Samples
-}

import Date exposing (Date)
import Dict exposing (Dict)


-- LOCAL IMPORTS

import Style


-- MODEL


type alias Session =
    { total : Int
    , list : List Investigation
    , criterion : Criterion
    , display : Style.Display
    , selection : Maybe Selection
    , searchDisplay : Style.Display
    , fieldDict : FieldDict
    , searching : List SearchClause
    , error : Maybe String
    , page : Int
    , perPage : Int
    , filterName : String
    }


type alias SearchClause =
    { fieldName : String
    , operator : String
    , value : String
    }


type alias FieldSpec =
    { type_ : FieldType }


type FieldType
    = StringType
    | IntegerType


type alias FieldDict =
    Dict String FieldSpec


initSession =
    Session 0 [] AllInvestigations Style.Hide Nothing Style.Hide initFieldDict [] Nothing 1 10 ""


initFieldDict : FieldDict
initFieldDict =
    Dict.fromList
        [ ( "description", FieldSpec StringType )
        , ( "project_name", FieldSpec StringType )
        ]


type alias ID =
    Int


type alias Investigation =
    { id : ID
    , project_name : String
    , experimental_factor : String -- Attribute
    , investigation_type : String -- Attribute
    , submitted_to_insdc : Bool
    , availability : String -- Attribute
    , completion_date : Maybe Date
    , ncbi_project_id : String
    , investigation_description : String
    }


type alias Description =
    String


type Criterion
    = AllInvestigations
    | InvestigationForSample ID Description


type alias InvestigationsPayload =
    { investigationCount : Int, investigations : List Investigation }


type alias Selection =
    { investigation : Investigation
    , display : Style.Display
    }


type Msg
    = Response ( InvestigationsPayload, Criterion, Style.Display )
    | RequestError String


type Action
    = ShowHide
    | Select Investigation
    | ToggleInfosheet
    | CloseInfosheet
    | Refresh
    | Search
    | NextPage
    | PreviousPage
    | ProjectName String
    | Description String


criterionToText : Criterion -> String
criterionToText criterion =
    case criterion of
        AllInvestigations ->
            " - All "

        InvestigationForSample id description ->
            " - for Sample " ++ description
