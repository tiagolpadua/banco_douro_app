import 'package:http_interceptor/http_interceptor.dart';
import 'package:logger/logger.dart';

/// Interceptador de Logging
///
/// Interceptadores permitem capturar requisicoes e respostas HTTP
/// automaticamente, util para debug e monitoramento.
class LoggingInterceptor extends InterceptorContract {
  Logger logger = Logger(printer: PrettyPrinter(methodCount: 0));

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    logger.t("Requisicao para: ${request.url}\n${request.headers}");
    return request;
  }

  @override
  Future<BaseResponse> interceptResponse({required BaseResponse response}) async {
    // Codigos 2xx indicam sucesso
    if (response.statusCode ~/ 100 == 2) {
      logger.i(
        "Resposta de ${response.request?.url}\n"
        "Status: ${response.statusCode}",
      );
    } else {
      logger.e(
        "Erro de ${response.request?.url}\n"
        "Status: ${response.statusCode}",
      );
    }
    return response;
  }
}
