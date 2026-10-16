HTML = """<!DOCTYPE html>
<html>
<head><title>AutomationEC2instance</title></head>
<body>
<p>Nadav MA KORE YA Manyuk</p>
<p><a href="game">Spivak If you get bored, here is one game to pass the time on the flight or in South Africa.</a></p>
</body>
</html>
"""


def page(event, context):
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "text/html; charset=utf-8"},
        "body": HTML,
    }
