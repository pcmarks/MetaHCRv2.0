module OrganismTypes exposing (..)

{-| Type support for Samples
-}

-- LOCAL IMPORTS

import Style


-- MODEL


type alias Session =
    { total : Int
    , list : List Organism
    , criterion : Criterion
    , display : Style.Display
    , selection : Maybe Selection
    , error : Maybe String
    , page : Int
    , perPage : Int
    }


initSession =
    Session 0 [] AllOrganisms Style.Hide Nothing Nothing 1 10


type alias Organism =
    { id : Int
    , superkingdom : String
    , phylum : String
    , subphylum : String
    , bio_class : String
    , bio_order : String
    , family : String
    , genus : String
    , species : String
    }


type Criterion
    = AllOrganisms
    | OrganismsForBiologicalAnalysis Int


type alias OrganismsPayload =
    { organismCount : Int, organisms : List Organism }


type alias Selection =
    { organism : Organism
    , display : Style.Display
    }


type Msg
    = Response ( OrganismsPayload, Criterion )
    | RequestError String


type Action
    = ShowHide
    | Select Organism
    | ToggleInfosheet
    | CloseInfosheet
    | Refresh
    | NextPage
    | PreviousPage


criterionToText : Criterion -> String
criterionToText criterion =
    case criterion of
        AllOrganisms ->
            " - All "

        OrganismsForBiologicalAnalysis id ->
            " - for Biological Analysis Id " ++ (toString id)
