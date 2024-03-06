ExUnit.start()

# Mock for Unique ID Sequencer used by the Short URLs
Mox.defmock(UniqueIdSequencerMock, for: UrlShortener.Behaviors.UniqueIdSequencer)
Application.put_env(:url_shortener, :short_url_id_sequencer, UniqueIdSequencerMock)

# Mock for URL Encoder
Mox.defmock(UrlEncoderMock, for: UrlShortener.Behaviors.UrlEncoder)
Application.put_env(:url_shortener, :url_encoder, UrlEncoderMock)

Ecto.Adapters.SQL.Sandbox.mode(UrlShortener.Repo, :manual)
