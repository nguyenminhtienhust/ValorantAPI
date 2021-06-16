import Foundation

public enum Agent {
	public typealias ID = ObjectID<Self, UUID>
}

public extension Agent.ID {
	static let breach = Self(stringValue: "5f8d3a7f-467b-97f3-062c-13acf203c006")!
	static let raze = Self(stringValue: "f94c3b30-42be-e959-889c-5aa313dba261")!
	static let skye = Self(stringValue: "6f2a04ca-43e0-be17-7f36-b3908627744d")!
	static let cypher = Self(stringValue: "117ed9e3-49f3-6512-3ccf-0cada7e3823b")!
	static let sova = Self(stringValue: "320b2a48-4d9b-a075-30f1-1f93a9b638fa")!
	static let killjoy = Self(stringValue: "1e58de9c-4950-5125-93e9-a0aee9f98746")!
	static let viper = Self(stringValue: "707eab51-4836-f488-046a-cda6bf494859")!
	static let phoenix = Self(stringValue: "eb93336a-449b-9c1b-0a54-a891f7921d69")!
	static let astra = Self(stringValue: "41fb69c1-4189-7b37-f117-bcaf1e96f1bf")!
	static let brimstone = Self(stringValue: "9f0d8ba9-4140-b941-57d3-a7ad57c6b417")!
	static let yoru = Self(stringValue: "7f94d92c-4234-0a36-9646-3a87eb8b5c89")!
	static let sage = Self(stringValue: "569fdd95-4d10-43ab-ca70-79becc718b46")!
	static let reyna = Self(stringValue: "a3bfb853-43b2-7238-a4f1-ad90e9e46bcc")!
	static let omen = Self(stringValue: "8e253930-4c05-31dd-1b6c-968525494517")!
	static let jett = Self(stringValue: "add6443a-41bd-e414-f6ad-e58d267f4e95")!
}
