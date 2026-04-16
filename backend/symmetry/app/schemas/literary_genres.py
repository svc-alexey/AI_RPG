from pydantic import BaseModel


class LiteraryGenreResponse(BaseModel):
    slug: str
    title_en: str
    title_ru: str
    sort_order: int
