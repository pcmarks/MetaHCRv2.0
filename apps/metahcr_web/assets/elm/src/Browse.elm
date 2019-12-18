module Browse exposing (Session, Msg(..), init, load, update, view)

{-| The Browse module supplies the initializing, updating, and viewing of the
application's browsing user facility. Most of the functions delegate to the
viewing and updating of the entities: Investigations, Samples, and Biological Analyses.
-}

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


-- LOCAL IMPORTS

import InvestigationRest as IR
import InvestigationTypes as IT
import InvestigationSession as IS
import SampleRest as SR
import SampleTypes as ST
import SampleSession as SS
import SingleGeneAnalysisRest as SGAR
import SingleGeneAnalysisTypes as SGAT
import SingleGeneAnalysisSession as SGAS
import OrganismRest as OR
import OrganismTypes as OT
import OrganismSession as OS
import Style


-- TYPES
{- The Browse Session -}


type alias Session =
    { investigationSession : IT.Session
    , sampleSession : ST.Session
    , singleGeneAnalysisSession : SGAT.Session
    , organismSession : OT.Session
    }


type Msg
    = IMsg IT.Action
    | SMsg ST.Action
    | SGAMsg SGAT.Action
    | OMsg OT.Action
    | IRestMsg IT.Msg
    | SRestMsg ST.Msg
    | SGARestMsg SGAT.Msg
    | ORestMsg OT.Msg



-- STATE


init : Session
init =
    Session IT.initSession
        ST.initSession
        SGAT.initSession
        OT.initSession


load : Cmd Msg
load =
    Cmd.batch
        [ Cmd.map IRestMsg (IR.requestInvestigations IT.AllInvestigations Style.Hide 1 10)
        , Cmd.map SRestMsg (SR.requestSamples ST.AllSamples Style.Hide 1 10)
        , Cmd.map SGARestMsg (SGAR.requestSingleGeneAnalyses SGAT.AllSingleGeneAnalyses Style.Hide 1 10)
        , Cmd.map ORestMsg (OR.requestOrganisms OT.AllOrganisms 3 10)
        ]



-- UPDATE


{-| Because the selection of one entity (Investigation, Sample or Biological Analysis)
can result in the retrieval of related data, the entity's update function returns
three commands corresponding to the queries that must be acted upon.
The Cmds are tagged appropriately. In some cases, Cmd.none will be returned.
See the entity's update function for details.
-}
batchCmds : Cmd IT.Msg -> Cmd ST.Msg -> Cmd SGAT.Msg -> Cmd OT.Msg -> Cmd Msg
batchCmds iMsg sMsg baMsg oMsg =
    Cmd.batch
        [ Cmd.map IRestMsg iMsg
        , Cmd.map SRestMsg sMsg
        , Cmd.map SGARestMsg baMsg
        , Cmd.map ORestMsg oMsg
        ]


update : Msg -> Session -> ( Session, Cmd Msg )
update msg session =
    case msg of
        IMsg action ->
            let
                -- Note the three Cmd's returned. Some may be Cmd.none
                ( newISession, investigationCmd, sampleCmd, singleGeneAnalysisCmd ) =
                    IS.update action session.investigationSession
            in
                ( { session | investigationSession = newISession }
                , batchCmds investigationCmd sampleCmd singleGeneAnalysisCmd Cmd.none
                )

        IRestMsg restMsg ->
            ( { session
                | investigationSession = IS.updateSession restMsg session.investigationSession
              }
            , Cmd.none
            )

        SMsg action ->
            let
                ( newSSession, investigationCmd, sampleCmd, singleGeneAnalysisCmd ) =
                    SS.update action session.sampleSession
            in
                ( { session | sampleSession = newSSession }
                , batchCmds investigationCmd sampleCmd singleGeneAnalysisCmd Cmd.none
                )

        SRestMsg restMsg ->
            ( { session
                | sampleSession = SS.updateSession restMsg session.sampleSession
              }
            , Cmd.none
            )

        SGARestMsg restMsg ->
            ( { session
                | singleGeneAnalysisSession = SGAS.updateSession restMsg session.singleGeneAnalysisSession
              }
            , Cmd.none
            )

        SGAMsg action ->
            let
                ( newSGASession, investigationCmd, sampleCmd, singleGeneAnalysisCmd ) =
                    SGAS.update action session.singleGeneAnalysisSession
            in
                ( { session | singleGeneAnalysisSession = newSGASession }
                , batchCmds investigationCmd sampleCmd singleGeneAnalysisCmd Cmd.none
                )

        OMsg action ->
            let
                ( newOSession, sampleCmd, organismCmd ) =
                    OS.update action session.organismSession
            in
                ( { session | organismSession = newOSession }
                , batchCmds Cmd.none sampleCmd Cmd.none organismCmd
                )

        ORestMsg restMsg ->
            ( { session
                | organismSession = OS.updateSession restMsg session.organismSession
              }
            , Cmd.none
            )



-- VIEW


entitySeparator : Html Msg
entitySeparator =
    div [ class "w3-bar w3-black" ]
        [ div [ class "w3-bar-item" ] [ text "  " ] ]


view : Session -> Html Msg
view session =
    div []
        [ entitySeparator
        , Html.map IMsg (IS.view session.investigationSession)
        , entitySeparator
        , Html.map SMsg (SS.view session.sampleSession)
        , entitySeparator
        , Html.map SGAMsg (SGAS.view session.singleGeneAnalysisSession)
        , entitySeparator
        , Html.map OMsg (OS.view session.organismSession)
        , entitySeparator
        ]
