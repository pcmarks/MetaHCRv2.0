module MainRest exposing (requestCounts, requestLogin)

{- ! Support for the top-level Main module. It's primary responsibility is
   to retrieve counts of the database entities by querying the Phoenix Server
-}

import Http exposing (Request)
import Json.Decode exposing (map, int, string, list, Decoder)
import Json.Decode.Pipeline as Pipeline exposing (decode, required)
import Json.Encode


--- LOCAL IMPORTS

import MainTypes exposing (..)


baseUrl =
    "http://localhost:4000"


browseUrl : String
browseUrl =
    baseUrl ++ "/browse"


requestLogin : String -> String -> Cmd Msg
requestLogin user pw =
    Http.send
        (\result ->
            case result of
                Ok loginStatus ->
                    LoginResponse loginStatus

                Err httpErr ->
                    RequestError (toString httpErr)
        )
        (login user pw)


login : String -> String -> Request LoginStatus
login user pw =
    Http.post
        (baseUrl
            ++ "/login"
            ++ "?_user="
            ++ user
            ++ "&_password="
            ++ pw
        )
        Http.emptyBody
        loginResponseDecoder


loginResponseDecoder : Decoder LoginStatus
loginResponseDecoder =
    decode LoginStatus
        |> Pipeline.required "user" string
        |> Pipeline.required "status" string


requestCounts : Cmd Msg
requestCounts =
    Http.send
        (\result ->
            case result of
                Ok counts ->
                    Response counts

                Err httpErr ->
                    RequestError (toString httpErr)
        )
        getCounts


getCounts : Request DataCounts
getCounts =
    Http.get browseUrl countsDecoder


countsDecoder : Decoder DataCounts
countsDecoder =
    decode DataCounts
        |> Pipeline.required "investigation_count" int
        |> Pipeline.required "sample_count" int
        |> Pipeline.required "analysis_count" int
        |> Pipeline.required "organism_count" int
