import Foundation
import Protoquest
import HandyOperators

extension ValorantClient {
	/// Gets the live match (or pregame/agent select) a player is currently in.
	public func getLiveMatch(inPregame: Bool) async throws -> Match.ID? {
		do {
			return try await send(LivePlayerInfoRequest(
				playerID: userID, inPregame: inPregame, location: location
			)).matchID
		} catch APIError.resourceNotFound {
			return nil
		}
	}
	
	/// Gets the pregame (agent select) info for a match in that state.
	public func getLivePregameInfo(_ matchID: Match.ID) async throws -> LivePregameInfo {
		try await send(LiveMatchInfoRequest<LivePregameInfo>(
			matchID: matchID, inPregame: true, location: location
		))
	}
	
	/// Gets the live game info for a running match.
	public func getLiveGameInfo(_ matchID: Match.ID) async throws -> LiveGameInfo {
		try await send(LiveMatchInfoRequest<LiveGameInfo>(
			matchID: matchID, inPregame: false, location: location
		))
	}
	
	/// Selects or locks in an agent.
	public func pickAgent(
		_ agentID: Agent.ID, in matchID: Match.ID,
		shouldLock: Bool
	) async throws -> LivePregameInfo {
		try await send(PickAgentRequest(
			matchID: matchID, agentID: agentID,
			shouldLock: shouldLock,
			location: location
		))
	}
	
	/// Selects an agent without locking in.
	public func selectAgent(_ agentID: Agent.ID, in matchID: Match.ID) async throws -> LivePregameInfo {
		try await pickAgent(agentID, in: matchID, shouldLock: false)
	}
	
	/// Locks in an agent (ideally previously selected).
	public func lockInAgent(_ agentID: Agent.ID, in matchID: Match.ID) async throws -> LivePregameInfo {
		try await pickAgent(agentID, in: matchID, shouldLock: true)
	}
}

private struct LivePlayerInfoRequest: GetJSONRequest, LiveGameRequest {
	var playerID: Player.ID
	var inPregame: Bool
	var location: Location
	
	var path: String {
		"/v1/players/\(playerID)"
	}
	
	struct Response: Decodable {
		var matchID: Match.ID
		
		private enum CodingKeys: String, CodingKey {
			case matchID = "MatchID"
		}
	}
}

private struct LiveMatchInfoRequest<Response: Decodable>: GetJSONRequest, LiveGameRequest {
	var matchID: Match.ID
	var inPregame: Bool
	var location: Location
	
	var path: String {
		"/v1/matches/\(matchID)"
	}
}

private struct PickAgentRequest: GetJSONRequest, LiveGameRequest {
	var httpMethod: String { "POST" }
	
	var matchID: Match.ID
	var agentID: Agent.ID
	var shouldLock: Bool
	
	var inPregame: Bool { true }
	var location: Location
	
	var path: String {
		"/v1/matches/\(matchID)/\(shouldLock ? "lock" : "select")/\(agentID)"
	}
	
	typealias Response = LivePregameInfo
}

private protocol LiveGameRequest: Request {
	var location: Location { get }
	var inPregame: Bool { get }
}

extension LiveGameRequest {
	var baseURLOverride: URL? {
		BaseURLs.liveGameAPI(location: location)
			.appendingPathComponent(inPregame ? "pregame" : "core-game")
	}
}
