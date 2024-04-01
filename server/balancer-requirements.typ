= Requirements <Chapter::balancer-requirements>

== Introduction

As elaborated in @Chapter::SolutionOverview, the goal is to create a load balancer that meets the requirements specified in this chapter.

== Stakeholders

- End Users
  - People that use any instance of OTT to watch videos
- Self-hosters
   - People that host their own instance of OTT
- Developers/Maintainers
  - The authors of this document
- Fly.io
  - The platform that hosts OTT
- Video Providers
  - The platforms that host the videos that are watched on OTT
  - YouTube, Vimeo, etc.

== Key Concepts

See @glossary

#import "lib/requirements.typ": *

== User Requirements <Section::req-user>

#figure(
  table(
    columns: 1,
    [#req("Current End User Experience must be maintained or improved", mustHave, usecase: [@UseCase::end-user])],
    [#req("Self-hosters must not be required to use the load balancer", mustHave, usecase: [@UseCase::self-host])],
    [#req("Must not allow multiple Monoliths to load the same room at the same time", mustHave, usecase: [@UseCase::end-user]) <Req::room-uniqueness>],
    [#req("Must not allow external users to pose as a Monolith to the Balancer", mustHave)],
    [#req("Must provide sufficient configurability", mustHave, usecase: [@UseCase::maintaining])],
    [#req("Should be easily configurable", shouldHave, usecase: [@UseCase::maintaining])],
    [#req("Should not require any external services (like Redis or Kafka)", shouldHave)],
    [#req("System must route traffic to the closest region", mustHave, usecase: [@UserStory::Responsive])],
    [#req("Clients must be able to interface with OTT with and without the Balancer with minimal code changes.", mustHave, usecase: [@UseCase::end-user])],
    [#req("Should listen on both IPv4 ports and IPv6 ports addresses", shouldHave)],
    [#req("Must prioritize routing requests to monoliths in the same region as the balancer", mustHave, usecase: [@UserStory::Responsive])],
    [#req("Must be able to route requests to any region", mustHave, usecase: [@UseCase::end-user])],
    [#req("Balancer can be configured with new routing rules without recompiling", wouldBeNiceToHave, usecase: [@UseCase::maintaining])],
    [#req("Balancer is able to work on protocols other than HTTP", wouldBeNiceToHave, usecase: [@UseCase::maintaining])],
    [#req("Any deployment of OTT must appear from the outside to be a single entity. Users must not need to manually select what server they are connecting to.", mustHave, usecase: [@UseCase::end-user]) <Req::single-entity>],
  ),
  caption: [Balancer User Requirements]
)

== System Requirements <Section::req-system>

#figure(
  table(
    columns: 1,
    [#req("Should fit within Fly.io's smallest machine (1 core, 256 MB RAM)", shouldHave, usecase: [@UseCase::maintaining])],
    [#req("Must be runnable in a Docker container", mustHave, usecase: [@UseCase::maintaining, @UseCase::self-host])],
    [#req("Should minimize Docker image size", shouldHave, usecase: [@UseCase::maintaining, @UseCase::end-user])],
    [#req("Must interface with visualization", mustHave, usecase: [@UseCase::visualization-interface])]
  ),
  caption: [Balancer System Requirements]
)

== Non-Functional Requirements <Section::req-nonfunc>

#figure(
  table(
    columns: 1,
    [#req("Capable of handling current OTT traffic (about 80 concurrent users max)", mustHave, usecase: [@UseCase::end-user, @UserStory::WatchTogether])],
    [#req("Must run on Linux", mustHave, usecase: [@UseCase::maintaining, @UseCase::self-host])],
    [#req("Must run in Docker", mustHave, usecase: [@UseCase::maintaining, @UseCase::self-host])],
    [#req("Must be very fault tolerant", mustHave, usecase: [@UseCase::maintaining, @UserStory::Reliable])],
    [#req("Clients must be able to interface with OTT with and without the Balancer with minimal code changes.", mustHave, usecase: [@UseCase::end-user])],
    [#req("Must be safe to scale horizontally", mustHave, usecase: [@UseCase::maintaining, @UserStory::Reliable])],
    [#req("Must be safe to do multi-region deployments", mustHave, usecase: [@UseCase::maintaining, @UserStory::Responsive])],
  ),
  caption: [Balancer Non-Functional Requirements]
)

== Domain Requirements <Section::req-domain>

#figure(
  table(
    columns: 1,
    [#req("Balancer should follow best practices with regards to HTTP", couldHave, usecase: [@UseCase::end-user, @UserStory::HttpApi])],
    [#req("OTT must remain in compliance with the YouTube API Terms of Service", mustHave, usecase: [@UseCase::maintaining])],
    [#req("The Balancer must comply with the GDPR.", mustHave, usecase: [@UseCase::maintaining])],
  ),
  caption: [Balancer Domain Requirements]
)
