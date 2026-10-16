import base64
import json
import os
import secrets
import time
import uuid
from pathlib import Path

import boto3
from botocore.exceptions import ClientError

from wordle import ANSWERS, MAX_GUESSES, WORD_LENGTH, is_valid_guess, score

GAME_TTL_SECONDS = 24 * 60 * 60
GAME_HTML = (Path(__file__).parent / "game.html").read_text(encoding="utf-8")

table = boto3.resource("dynamodb").Table(os.environ["GAMES_TABLE"])


def _json(status, body):
    return {
        "statusCode": status,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body),
    }


def _body(event):
    raw = event.get("body") or "{}"
    if event.get("isBase64Encoded"):
        raw = base64.b64decode(raw).decode("utf-8")
    try:
        data = json.loads(raw)
    except json.JSONDecodeError:
        return None
    return data if isinstance(data, dict) else None


def page(event, context):
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "text/html; charset=utf-8"},
        "body": GAME_HTML,
    }


def new_game(event, context):
    game_id = str(uuid.uuid4())
    table.put_item(
        Item={
            "gameId": game_id,
            "answer": secrets.choice(ANSWERS),
            "guesses": [],
            "status": "playing",
            "expiresAt": int(time.time()) + GAME_TTL_SECONDS,
        }
    )
    return _json(201, {"gameId": game_id, "wordLength": WORD_LENGTH, "maxGuesses": MAX_GUESSES})


def guess(event, context):
    data = _body(event)
    if data is None:
        return _json(400, {"error": "Request body must be JSON."})

    game_id = data.get("gameId")
    word = data.get("guess")
    if not isinstance(game_id, str) or not game_id:
        return _json(400, {"error": "Missing game id."})
    if not is_valid_guess(word):
        return _json(400, {"error": f"Guess must be {WORD_LENGTH} letters."})
    word = word.lower()

    item = table.get_item(Key={"gameId": game_id}).get("Item")
    if not item:
        return _json(404, {"error": "Game not found. Start a new game."})
    if item["status"] != "playing":
        return _json(409, {"error": "This game is over. Start a new game."})

    answer = item["answer"]
    guesses = item["guesses"]
    result = score(word, answer)
    guesses_after = guesses + [word]

    if word == answer:
        status = "won"
    elif len(guesses_after) >= MAX_GUESSES:
        status = "lost"
    else:
        status = "playing"

    try:
        table.update_item(
            Key={"gameId": game_id},
            UpdateExpression="SET guesses = :after, #s = :status",
            ConditionExpression="guesses = :before AND #s = :playing",
            ExpressionAttributeNames={"#s": "status"},
            ExpressionAttributeValues={
                ":after": guesses_after,
                ":before": guesses,
                ":status": status,
                ":playing": "playing",
            },
        )
    except ClientError as error:
        if error.response["Error"]["Code"] == "ConditionalCheckFailedException":
            return _json(409, {"error": "Game changed in another tab. Reload and try again."})
        raise

    body = {
        "guess": word,
        "result": result,
        "status": status,
        "remaining": MAX_GUESSES - len(guesses_after),
    }
    if status != "playing":
        body["answer"] = answer
    return _json(200, body)
