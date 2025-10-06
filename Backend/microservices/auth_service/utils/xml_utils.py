# auth_service/utils/xml_utils.py
import xmltodict, dicttoxml
from fastapi import Response

def parse_xml(body: bytes) -> dict:
    return xmltodict.parse(body)

def to_xml(data: dict) -> Response:
    return Response(content=dicttoxml.dicttoxml(data, custom_root='response', attr_type=False), media_type="application/xml")
