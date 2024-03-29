import Foundation
import Protoquest

extension ValorantClient {
	/// Gets the inventory, i.e. all owned items (like agents and player cards and such). Only allowed on the currently signed-in user.
	public func getInventory(for playerID: Player.ID) async throws -> Inventory {
		Inventory(try await send(InventoryRequest(playerID: playerID)))
	}
}

private struct InventoryRequest: GetJSONRequest {
	var playerID: Player.ID
	
	var path: String {
		"/store/v1/entitlements/\(playerID)"
	}
	
	typealias Response = APIInventory
}
