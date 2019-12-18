module SingleGeneAnalysisTypes exposing (..)

{-| Type support for Single Gene biologicalAnalyses
-}

-- LOCAL IMPORTS

import Style


-- MODEL


type alias Session =
    { total : Int
    , list : List SingleGeneAnalysis
    , criterion : Criterion
    , display : Style.Display
    , selection : Maybe Selection
    , error : Maybe String
    , page : Int
    , perPage : Int
    , results : Maybe Results
    }


initSession =
    Session 0 [] AllSingleGeneAnalyses Style.Hide Nothing Nothing 1 10 Nothing


type alias ID =
    Int


type alias SingleGeneAnalysis =
    { analysis_id : Int
    , analysis_name : String
    , target_gene : String
    , pcr_primers : String
    , sample_id : Int
    }


type alias Description =
    String


type Criterion
    = AllSingleGeneAnalyses
    | SingleGeneAnalysesForSample ID Description


type alias SingleGeneAnalysesPayload =
    { count : Int, single_gene_analyses : List SingleGeneAnalysis }


type alias SingleGeneResult =
    { organism_id : Int
    , score : String
    , phylum : String
    , subphylum : String
    , bio_class : String
    , bio_order : String
    , family : String
    , genus : String
    , species : String
    }


type alias SingleGeneResultsPayload =
    { count : Int, single_gene_results : List SingleGeneResult }


type alias Selection =
    { analysis : SingleGeneAnalysis
    , display : Style.Display
    }


type alias Results =
    { resultsList : List SingleGeneResult
    , display : Style.Display
    }


type Msg
    = AnalysesResponse ( SingleGeneAnalysesPayload, Criterion, Style.Display )
    | ResultsResponse SingleGeneResultsPayload
    | RequestError String


type Action
    = ShowHide
    | Select SingleGeneAnalysis
    | ToggleInfosheet
    | CloseInfosheet
    | SelectResult SingleGeneResult
    | ToggleResults
    | CloseResults
    | Refresh
    | NextPage
    | PreviousPage


criterionToText : Criterion -> String
criterionToText criterion =
    case criterion of
        AllSingleGeneAnalyses ->
            " - All "

        SingleGeneAnalysesForSample id description ->
            " - for Sample " ++ description
