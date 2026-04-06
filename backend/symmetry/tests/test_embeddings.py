from pathlib import Path

from app.services import embeddings


class _FakeVector:
    def __init__(self, values: list[float]) -> None:
        self._values = values

    def tolist(self) -> list[float]:
        return list(self._values)


class _FakeSentenceTransformer:
    def __init__(self, model_name: str, **kwargs) -> None:
        self.model_name = model_name
        self.kwargs = kwargs
        self.calls: list[list[str]] = []

    def encode(self, texts: list[str], *, batch_size: int, normalize_embeddings: bool):
        assert batch_size == 32
        assert normalize_embeddings is True
        self.calls.append(list(texts))
        return [_FakeVector([0.1, 0.2, 0.3]) for _ in texts]


class _FakeSettings:
    embedding_model = "intfloat/multilingual-e5-base"
    embedding_backend = "onnx"
    embedding_model_file_name = "onnx/model.onnx"
    embedding_model_dir = Path("models")
    embedding_batch_size = 32
    embedding_cache_size = 8
    embedding_cache_ttl_seconds = 60


def test_embedding_service_uses_onnx_and_query_cache(monkeypatch):
    instances: list[_FakeSentenceTransformer] = []

    def _factory(model_name: str, **kwargs):
        instance = _FakeSentenceTransformer(model_name, **kwargs)
        instances.append(instance)
        return instance

    monkeypatch.setattr(embeddings, "SentenceTransformer", _factory)
    monkeypatch.setattr(embeddings, "get_settings", lambda: _FakeSettings())

    service = embeddings.EmbeddingService()

    first = service.encode_query("  what   happened ")
    second = service.encode_query("what happened")

    assert first == [0.1, 0.2, 0.3]
    assert second == [0.1, 0.2, 0.3]
    assert len(instances) == 1
    assert instances[0].kwargs["backend"] == "onnx"
    assert instances[0].kwargs["model_kwargs"] == {"file_name": "onnx/model.onnx"}
    assert instances[0].calls == [["query: what happened"]]

    runtime_state = service.runtime_state()
    assert runtime_state["cache_hits"] == 1
    assert runtime_state["cache_misses"] == 1
    assert runtime_state["vector_dimension"] == 3


def test_embedding_service_encodes_documents_with_passage_prefix(monkeypatch):
    instances: list[_FakeSentenceTransformer] = []

    def _factory(model_name: str, **kwargs):
        instance = _FakeSentenceTransformer(model_name, **kwargs)
        instances.append(instance)
        return instance

    monkeypatch.setattr(embeddings, "SentenceTransformer", _factory)
    monkeypatch.setattr(embeddings, "get_settings", lambda: _FakeSettings())

    service = embeddings.EmbeddingService()

    vector = service.encode_document("  ancient   market fire ")

    assert vector == [0.1, 0.2, 0.3]
    assert instances[0].calls == [["passage: ancient market fire"]]
