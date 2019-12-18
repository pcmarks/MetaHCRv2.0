module OrganismRest exposing (requestOrganisms)

{-| This module provides database query support for Organisms.
-}

import Http exposing (Request)
import Json.Decode exposing (map, int, string, list, Decoder)
import Json.Decode.Pipeline as Pipeline exposing (decode, required)
import Json.Encode


-- LOCAL IMPORTS

import Rest exposing (..)
import OrganismTypes exposing (..)


requestOrganisms : Criterion -> Int -> Int -> Cmd Msg
requestOrganisms criterion page perPage =
    Http.send
        (\result ->
            case result of
                Ok organismsPayload ->
                    Response ( organismsPayload, criterion )

                Err httpErr ->
                    RequestError (toString httpErr)
        )
        -- (Result HttpError val -> msg)
        (getOrganisms criterion page perPage)



-- Request val


getOrganisms : Criterion -> Int -> Int -> Request OrganismsPayload
getOrganisms criterion page perPage =
    let
        parms =
            case criterion of
                AllOrganisms ->
                    organismsParms page perPage

                OrganismsForBiologicalAnalysis analysisId ->
                    organismsParms page perPage
                        ++ ("&analysis_id=" ++ (toString analysisId))
    in
        Http.get (browseUrl ++ "/organism" ++ parms) organismsDecoder


organismsParms : Int -> Int -> String
organismsParms startPage itemCount =
    "?page=" ++ (toString startPage) ++ "&itemcount=" ++ (toString itemCount)


organismsDecoder : Decoder OrganismsPayload
organismsDecoder =
    decode OrganismsPayload
        |> Pipeline.required "count" int
        |> Pipeline.required "organisms" (Json.Decode.list investigationDecoder)


investigationDecoder : Decoder Organism
investigationDecoder =
    decode Organism
        |> Pipeline.required "id" int
        |> Pipeline.required "superkingdom" string
        |> Pipeline.required "phylum" string
        |> Pipeline.required "subphylum" string
        |> Pipeline.required "bio_class" string
        |> Pipeline.required "bio_order" string
        |> Pipeline.required "family" string
        |> Pipeline.required "genus" string
        |> Pipeline.required "species" string
