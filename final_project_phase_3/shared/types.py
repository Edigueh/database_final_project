from typing import TypeAlias

from sqlalchemy.sql import Executable

DatabaseRow: TypeAlias = tuple[object, ...]
QueryStatement: TypeAlias = Executable | str
