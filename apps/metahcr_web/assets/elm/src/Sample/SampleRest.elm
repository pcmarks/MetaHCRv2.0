module SampleRest exposing (requestSamples)

{-| This module provides database query support for Samples.
-}

import Http exposing (Request)
import Json.Decode exposing (map, int, string, list, Decoder)
import Json.Decode.Pipeline as Pipeline exposing (decode, required)
import Json.Encode


-- LOCAL IMPORTS

import Rest exposing (..)
import SampleTypes exposing (..)
import Style exposing (Display)


requestSamples : Criterion -> Display -> Int -> Int -> Cmd Msg
requestSamples criterion display page perPage =
    Http.send
        (\result ->
            case result of
                Ok samplesPayload ->
                    Response ( samplesPayload, criterion, display )

                Err httpErr ->
                    RequestError (toString httpErr)
        )
        (getSamples criterion display page perPage)


getSamples : Criterion -> Display -> Int -> Int -> Request SamplesPayload
getSamples criterion display page perPage =
    let
        parms =
            case criterion of
                AllSamples ->
                    samplesParms page perPage

                SamplesForInvestigation investigationId description ->
                    samplesParms page perPage
                        ++ ("&inv_id=" ++ (toString investigationId))

                SampleForSingleGeneAnalysis biologicalAnalysisId description ->
                    samplesParms page perPage
                        ++ ("&anal_id=" ++ (toString biologicalAnalysisId))

                SamplesForOrganism organismId description ->
                    samplesParms page perPage
                        ++ ("&organism_id=" ++ (toString organismId))
    in
        Http.get (browseUrl ++ "/sample" ++ parms) samplesDecoder


samplesParms : Int -> Int -> String
samplesParms startPage itemCount =
    "?page=" ++ (toString startPage) ++ "&itemcount=" ++ (toString itemCount)


samplesDecoder : Decoder SamplesPayload
samplesDecoder =
    decode SamplesPayload
        |> Pipeline.required "count" int
        |> Pipeline.required "samples" (Json.Decode.list sampleDecoder)


sampleDecoder : Decoder Sample
sampleDecoder =
    decode Sample
        |> Pipeline.required "id" int
        |> Pipeline.required "source_mat_id" string
        |> Pipeline.required "samp_description" string
        |> Pipeline.required "samp_name" string
        |> Pipeline.required "samp_type" string
