module MainTypes exposing (DataCounts, LoginStatus, Msg(..))

{-| This module provides the types involved in handling the count of the system's
entities
-}


type alias DataCounts =
    { investigations : Int
    , samples : Int
    , analyses : Int
    , organisms : Int
    }


type alias User =
    Maybe String


type alias LoginStatus =
    { user : String
    , status : String
    }


type Msg
    = Response DataCounts
    | LoginResponse LoginStatus
    | RequestError String
