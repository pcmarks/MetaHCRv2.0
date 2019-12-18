module Misc exposing (date)

{-| Various and Sundry functions for general use
-}

-- IMPORTS

import Json.Decode exposing (Decoder, succeed, fail, string, andThen)
import Date exposing (Date)


date : Decoder Date
date =
    let
        convert : String -> Decoder Date
        convert raw =
            case Date.fromString raw of
                Ok date ->
                    succeed date

                Err error ->
                    fail error
    in
        string |> andThen convert
