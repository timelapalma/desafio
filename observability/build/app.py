import os
import logging
from random import randint

from flask import Flask, jsonify
from prometheus_flask_exporter import PrometheusMetrics


APP_NAME = "dice-api"


def create_app() -> Flask:
    app = Flask(__name__)

    app.config["JSON_SORT_KEYS"] = False

    configure_logging(app)

    # Prometheus com label padrão
    metrics = PrometheusMetrics(
        app,
        defaults={
            "app": APP_NAME
        }
    )

    metrics.info(
        "app_info",
        "Application info",
        version=os.getenv("APP_VERSION", "dev"),
    )

    register_routes(app)
    register_error_handlers(app)

    return app


def configure_logging(app: Flask) -> None:
    logging.basicConfig(
        level=os.getenv("LOG_LEVEL", "INFO"),
        format="%(asctime)s %(levelname)s %(name)s %(message)s",
    )
    app.logger.setLevel(logging.getLogger().level)


def register_routes(app: Flask) -> None:
    @app.route("/", methods=["GET"])
    def roll_dice():
        dice_value = randint(1, 6)
        app.logger.info(
            "Dice rolled",
            extra={"dice_value": dice_value, "app": APP_NAME},
        )
        return jsonify({"dice_value": dice_value})

    @app.route("/health", methods=["GET"])
    def health():
        return jsonify(
            {
                "status": "ok",
                "app": APP_NAME,
                "version": os.getenv("APP_VERSION", "dev"),
            }
        ), 200

    @app.route("/fail", methods=["GET"])
    def fail():
        raise RuntimeError("Intentional failure")


def register_error_handlers(app: Flask) -> None:
    @app.errorhandler(Exception)
    def handle_exception(error):
        app.logger.exception("Unhandled exception")
        return jsonify(
            {
                "error": "internal_server_error",
                "app": APP_NAME,
                "message": str(error),
            }
        ), 500


if __name__ == "__main__":
    app = create_app()
    app.run(
        host="0.0.0.0",
        port=int(os.getenv("PORT", 5000)),
    )
