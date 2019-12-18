module SingleGeneAnalysisRest exposing (..)

{-| This module provides database query support for Biological Analyses.
-}

import Http exposing (Request)
import Json.Decode exposing (map, int, string, list, Decoder)
import Json.Decode.Pipeline as Pipeline exposing (decode, required)
import Json.Encode


-- LOCAL IMPORTS

import Rest exposing (..)
import SingleGeneAnalysisTypes exposing (..)
import Style exposing (Display)


requestSingleGeneAnalyses : Criterion -> Display -> Int -> Int -> Cmd Msg
requestSingleGeneAnalyses criterion display page perPage =
    Http.send
        (\result ->
            case result of
                Ok singleGeneAnalysesPayload ->
                    AnalysesResponse ( singleGeneAnalysesPayload, criterion, display )

                Err httpErr ->
                    RequestError (toString httpErr)
        )
        (getSingleGeneAnalyses criterion display page perPage)


getSingleGeneAnalyses : Criterion -> Display -> Int -> Int -> Request SingleGeneAnalysesPayload
getSingleGeneAnalyses criterion display page perPage =
    let
        parms =
            case criterion of
                AllSingleGeneAnalyses ->
                    singleGeneAnalysesParms page perPage

                SingleGeneAnalysesForSample sampleId sampleDesc ->
                    singleGeneAnalysesParms page perPage
                        ++ ("&samp_id=" ++ (toString sampleId))
    in
        Http.get (browseUrl ++ "/single_gene_analysis" ++ parms) singleGeneAnalysesDecoder


singleGeneAnalysesParms : Int -> Int -> String
singleGeneAnalysesParms startPage itemCount =
    "?page=" ++ (toString startPage) ++ "&itemcount=" ++ (toString itemCount)


singleGeneAnalysesDecoder : Decoder SingleGeneAnalysesPayload
singleGeneAnalysesDecoder =
    decode SingleGeneAnalysesPayload
        |> Pipeline.required "count" int
        |> Pipeline.required "single_gene_analyses" (Json.Decode.list analysisDecoder)


analysisDecoder : Decoder SingleGeneAnalysis
analysisDecoder =
    decode SingleGeneAnalysis
        |> Pipeline.required "analysis_id" int
        |> Pipeline.required "analysis_name" string
        |> Pipeline.required "target_gene" string
        |> Pipeline.required "pcr_primers" string
        |> Pipeline.required "sample_id" int


requestSingleGeneResults : Int -> Int -> Int -> Cmd Msg
requestSingleGeneResults analysis_id page perPage =
    Http.send
        (\result ->
            case result of
                Ok singleGeneResultPayload ->
                    ResultsResponse (singleGeneResultPayload)

                Err httpErr ->
                    RequestError (toString httpErr)
        )
        (getSingleGeneResults analysis_id page perPage)


singleGeneResultsParms : Int -> Int -> String
singleGeneResultsParms startPage itemCount =
    "?page=" ++ (toString startPage) ++ "&itemcount=" ++ (toString itemCount)


getSingleGeneResults : Int -> Int -> Int -> Request SingleGeneResultsPayload
getSingleGeneResults analysis_id page perPage =
    let
        parms =
            singleGeneResultsParms page perPage
    in
        Http.get (browseUrl ++ "/single_gene_result" ++ parms ++ "&analysis_id=" ++ (toString analysis_id)) singleGeneResultsDecoder


singleGeneResultsDecoder : Decoder SingleGeneResultsPayload
singleGeneResultsDecoder =
    decode SingleGeneResultsPayload
        |> Pipeline.required "count" int
        |> Pipeline.required "single_gene_results" (Json.Decode.list resultDecoder)


resultDecoder : Decoder SingleGeneResult
resultDecoder =
    decode SingleGeneResult
        |> Pipeline.required "organism_id" int
        |> Pipeline.required "score" string
        |> Pipeline.required "phylum" string
        |> Pipeline.required "subphylum" string
        |> Pipeline.required "bio_class" string
        |> Pipeline.required "bio_order" string
        |> Pipeline.required "family" string
        |> Pipeline.required "genus" string
        |> Pipeline.required "species" string
