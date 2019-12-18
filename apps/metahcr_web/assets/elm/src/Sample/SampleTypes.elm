module SampleTypes exposing (..)

{-| Type support for Samples
-}

-- LOCAL IMPORTS

import Style


-- MODEL


type alias Session =
    { total : Int
    , list : List Sample
    , criterion : Criterion
    , display : Style.Display
    , selection : Maybe Selection
    , error : Maybe String
    , page : Int
    , perPage : Int
    }


initSession =
    Session 0 [] AllSamples Style.Hide Nothing Nothing 1 10


type alias ID =
    Int


type alias Sample =
    { id : ID
    , source_mat_id : String
    , samp_description : String
    , samp_name : String
    , samp_type : String
    }


type alias Description =
    String


type Criterion
    = AllSamples
    | SamplesForInvestigation ID Description
    | SampleForSingleGeneAnalysis ID Description
    | SamplesForOrganism ID Description


type alias SamplesPayload =
    { sampleCount : Int, samples : List Sample }


type alias Selection =
    { sample : Sample
    , display : Style.Display
    }


type Msg
    = Response ( SamplesPayload, Criterion, Style.Display )
    | RequestError String


type Action
    = ShowHide
    | Select Sample
    | ToggleInfosheet
    | CloseInfosheet
    | Refresh
    | NextPage
    | PreviousPage


criterionToText : Criterion -> String
criterionToText criterion =
    case criterion of
        AllSamples ->
            " - All "

        SamplesForInvestigation id description ->
            " - for Investigation " ++ (String.left 40 description)

        SampleForSingleGeneAnalysis id description ->
            " - for Single Gene Analysis " ++ description

        SamplesForOrganism id description ->
            " - for Organism " ++ description
