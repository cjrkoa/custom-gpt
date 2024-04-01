= Balancer Design

== Internal Architecture

#figure(
	image("figures/balancer-internals-class.svg"),
	caption: "Class diagram showing the structure and relationships between types in the Balancer.",
) <Figure::balancer-internals-class>

Shown in @Figure::balancer-internals-class is the internal structure of the Balancer. The Balancer will discover Monoiths using the `MonolithDiscoverer` (a process further described in @Chapter::ServiceDiscovery), and the `MonolithConnectionManager` will establish connections to each Monolith. `Balancer` will update `BalancerContext` according to the messages it receives from `BalancerLink`. `Balancer` will then use `BalancerContext` to route messages to the appropriate Monoliths. Clients work similarly, except that they establish connections to the Balancer via `BalancerService`. `BalancerService` handles proxying HTTP requests to the appropriate Monoliths, and also accepting and upgrading WebSocket connections.


#figure(
    image("figures/monolith-selection-internals-class.svg"),
    caption: "Class diagram showing the structure of MinRoomsSelector and the trait MonolithSelection and how they relate to BalancerContext.",
) <Figure::monolith-selection-internals-class>

== Package Structure

In Rust, packages are called "crates". The Balancer and Harness is split into multiple crates, as seen in @Figure::balancer-crates. The reason for this is that cargo, the Rust package manager, treats crates as the unit of compilation. This means that if you change a single line of code in a crate, the entire crate must be recompiled. By splitting the Balancer into multiple crates, we can reduce the amount of code that needs to be recompiled when a change is made.

#figure(
	image("figures/balancer-crates.svg"),
	caption: "Package diagram showing the Balancer and Harness crates.",
) <Figure::balancer-crates>

== Dependencies

#let cargo = toml("Cargo.toml")
#let crates = cargo.workspace.dependencies

#let build_table(data) = {
  let keys = data.keys()
	let rows = ()

	for (crate, entry) in data {
		if(type(entry) == str) {
			entry = (
				version: entry
			)
		}

		if(entry.keys().contains("path")) { continue }
		let row = (raw(crate),)

		if(entry.keys().contains("version")) {
			row.push(raw(entry.version))
		} else if(entry.keys().contains("git")) {
			let rev = if (entry.keys().contains("rev")) {entry.rev} else {"HEAD"}
			rev = [(commit: #raw(rev))]
			row.push([#link(entry.git, "from git") #rev])
		}

		if(entry.keys().contains("features")) {
			row.push(raw(entry.features.join(", ")))
		} else {
			row.push("")
		}

		rows.push(row)
	}

	set align(left)
	table(
		columns: 3,
		[*Crate*],[*Version*],[*Features*],
		..rows.flatten()
	)
}

#figure(
	build_table(crates),
	caption: figure.caption("External Rust dependencies required for all workspace crates", position: top)
)

== Development Environment

#let text-box = box.with(
	inset: 1em,
	stroke: 1pt + black,
	fill: luma(245),
)

In order for the Balancer to work with the Monolith, the Monolith must have load balancing enabled, otherwise it will not listen for incoming balancer connections. The following configuration should go in `env/base.toml` in order to enable load balancing:

`base.toml`

#text-box(
	raw("[balancing]\nenabled = true", lang: "toml"),
)

@Figure::ports-1-monolith and @Figure::ports-2-monolith, demonstrate how to set up any number of Balancers and Monoliths. The listening ports are configurable, and they are labeled on the diagrams in the format `ENVIRONMENT_VAR=value`. Additionally, corresponding balancer configurations are shown to the right of the diagrams.

#let dev-env-figure(path, caption, balancer-config, commands) = {
	figure(
		grid(
			rows: 2,
			gutter: 20pt,
			image(path),
			align(left)[
				#grid(
					columns: 2,
					gutter: 10pt,
					[
						`balancer.toml`

						#text-box(
							raw(balancer-config, lang: "toml"),
						)
					],
					[
						`Commands to run:`

						#text-box(
							raw(commands, lang: "bash"),
						)
					],

				)
			]
		),
		caption: caption,
	)
}

#dev-env-figure(
	"figures/dev-env/ports-1-monolith.svg",
	[Diagram showing how ports for each process should be configured for development, shown on the top. Note that the values shown in this diagram are the default values, so you shouldn't need to set any environment variables to get this configuration. However, you will need this specific config file for the balancer to work, shown on the bottom left.],
	"[discovery]\nmethod = \"manual\"\n\n[[discovery.monoliths]]\nhost = \"localhost\"\nport = 3002",
	"# Terminal 0 - Balancer\ncargo run --bin ott-balancer-bin -- --config-path env/balancer.toml\n# Terminal 1 - Monolith\nyarn run start",
) <Figure::ports-1-monolith>

#dev-env-figure(
	"figures/dev-env/ports-2-monolith.svg",
	[Diagram showing the same thing as @Figure::ports-1-monolith, but with two Monoliths instead of one. Note that for the 2nd Monolith, you *will* need to set the environment variables, as shown on the bottom right.],
	"[discovery]\nmethod = \"manual\"\n\n[[discovery.monoliths]]\nhost = \"localhost\"\nport = 3002\n\n[[discovery.monoliths]]\nhost = \"localhost\"\nport = 3004",
	"# Terminal 0 - Balancer\ncargo run --bin ott-balancer-bin -- --config-path env/balancer.toml\n# Terminal 1 - Monolith 0\nyarn run start\n# Terminal 2 - Monolith 1\nPORT=3003 BALANCING_PORT=3004 yarn run start",
) <Figure::ports-2-monolith>

== Observability and Metrics

The Balancer, like the Monolith, exports Prometheus metrics at the `/api/status/metrics` endpoint. These metrics can be scraped by a Prometheus server and visualized using Grafana. Fly automatically scrapes metrics from all applications and provides a Prometheus data source for Grafana. They also host a Grafana instance for us, but we host our own Grafana instance so that we can have alerting enabled, and more control over configuration.

#figure(
	image("figures/vis/prom-metrics-collection.svg"),
	caption: "Component diagram showing how the Balancer interacts with Fly, Prometheus, and Grafana. The same concept applies to the Monolith.",
) <Figure::prom-metrics-collection>

The Balancer also renders some text based on it's current internal state at the `/api/balancing` endpoint. This can be useful for debugging and understanding the current state of the Balancer. Currently, this endpoint renders text in a human readable format, but it could be modified to render JSON or another format instead. System visualization is specified in @Chapter::Visualization-Design.

== Message Routing

The Balancer routes messages such that messages sent from a client end up at the correct Monolith, and vice versa. The Balancer uses the `BalancerContext` to keep track of the state of the Monoliths and the clients, protected with a `Arc<RwLock<T>>`. To minimize the amount of locking and hashmap lookups necessary to route messages, the Balancer sets up direct channels between tasks such that incoming client messages are sent directly to the appropriate Monolith, as shown in @Figure::balancer-channels-client-monolith.

#figure(
	image("figures/balancer-channels-client-monolith.svg", width: 50%),
	caption: "Structural diagram showing the channels set up by the Balancer, which objects own which ends of the channels, and which direction messages flow. Solid lines represent channels.",
) <Figure::balancer-channels-client-monolith>
