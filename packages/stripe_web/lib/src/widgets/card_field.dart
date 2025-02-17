import 'dart:developer' as dev;
import 'dart:html';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe_web/src/utils.dart';
import 'package:stripe_js/stripe_js.dart';

import '../../flutter_stripe_web.dart';
import 'package:stripe_js/stripe_js.dart' as js;
import 'package:stripe_js/stripe_api.dart' as js;

const kCardFieldDefaultHeight = 10.0;
const kCardFieldDefaultFontSize = 17.0;

class WebCardField extends StatefulWidget {
  WebCardField({
    required this.controller,
    this.onCardChanged,
    Key? key,
    this.onFocus,
    this.style,
    this.placeholder,
    this.enablePostalCode = false,
    double? width,
    double? height = kCardFieldDefaultHeight,
    BoxConstraints? constraints,
    this.focusNode,
    this.autofocus = false,
    this.dangerouslyUpdateFullCardDetails = false,
  })  : assert(constraints == null || constraints.debugAssertIsValid()),
        constraints = (width != null || height != null)
            ? constraints?.tighten(width: width, height: height) ??
                BoxConstraints.tightFor(width: width, height: height)
            : constraints,
        super(key: key);

  final BoxConstraints? constraints;
  final CardFocusCallback? onFocus;
  final CardChangedCallback? onCardChanged;
  final CardStyle? style;
  final CardPlaceholder? placeholder;
  final bool enablePostalCode;
  final FocusNode? focusNode;
  final bool autofocus;
  final CardEditController controller;
  final bool dangerouslyUpdateFullCardDetails;
  @override
  WebStripeCardState createState() => WebStripeCardState();
}

class WebStripeCardState extends State<WebCardField> with CardFieldContext {
  CardEditController get controller => widget.controller;

  @override
  void initState() {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'stripe_card',
      (int viewId) => DivElement()
        ..id = 'card-element'
        ..style.border = 'none',
    );
    initStripe();
    super.initState();
  }

  js.CardPaymentElement? get element => WebStripe.element as js.CardPaymentElement?;
  set element(js.CardPaymentElement? value) => WebStripe.element = value;

  void initStripe() {
    attachController(controller);
    ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((timeStamp) {
      if (!widget.dangerouslyUpdateFullCardDetails) {
        if (kDebugMode && controller.details != const CardFieldInputDetails(complete: false)) {
          dev.log('WARNING! Initial card data value has been ignored. \n'
              '$kDebugPCIMessage');
        }
        ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((timeStamp) {
          updateCardDetails(
            const CardFieldInputDetails(complete: false),
            controller,
          );
          element = WebStripe.js.elements(createElementOptions()).createCard(createOptions())
            ..mount('#card-element')
            ..onBlur(requestBlur)
            ..onFocus(requestFocus)
            ..onChange(onCardChanged);
        });
      }
    });
  }

  void requestBlur(response) {
    _effectiveNode.unfocus();
  }

  void requestFocus(response) {
    _effectiveNode.requestFocus();
  }

  void onCardChanged(js.CardElementChangeEvent response) {
    final value = response.value;
    final postalCode = value?.postalCode;

    final details = CardFieldInputDetails(
      complete: response.complete,
      brand: response.brand,
      postalCode: postalCode,
    );
    widget.onCardChanged?.call(details);
    updateCardDetails(details, controller);
    return;
  }

  final FocusNode _focusNode = FocusNode(debugLabel: 'CardField');
  FocusNode get _effectiveNode => widget.focusNode ?? _focusNode;

  @override
  Widget build(BuildContext context) {
    final constraints = widget.constraints ?? const BoxConstraints.expand(height: kCardFieldDefaultHeight);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Focus(
        focusNode: _effectiveNode,
        child: ConstrainedBox(
          constraints: constraints,
          child: const HtmlElementView(viewType: 'stripe_card'),
        ),
      ),
    );
  }

  String _getBrandonTextFontCssSrc() {
    final isHttps = Uri.base.scheme == 'https';
    if (isHttps) {
      debugPrint('Loaded font from local assets');
      return Uri.base.origin + '/fonts.css';
    } else {
      debugPrint(
          'You are currently using this application in a non secure environment (http). In order to load the correct font you should use a secure environment (https) OR if localhost use the arugment "--web-browser-flag=--disable-web-security" when running "flutter run" or the fonts will not load.');
      return 'https://workplace.insighttimer.com/fonts.css';
    }
  }

  js.JsElementsCreateOptions createElementOptions() {
    final textColor = widget.style?.textColor;
    return js.JsElementsCreateOptions(
      fonts: [
        Font(
          family: 'Brandon Text',
          cssSrc: _getBrandonTextFontCssSrc(),
        )
      ],
      appearance: js.jsify(
        js.ElementAppearance(
          theme: js.ElementTheme.stripe,
          variables: {
            if (textColor != null) 'colorText': colorToCssString(textColor),
          },
        ).toJson(),
      ) as js.JsElementAppearance,
    );
  }

  String colorToCssString(Color color) {
    return 'rgb(${color.red}, ${color.green}, ${color.blue})';
  }

  js.CardElementOptions createOptions() {
    return js.CardElementOptions(hidePostalCode: !widget.enablePostalCode, style: {
      'base': {
        if (widget.style?.fontFamily != null) 'fontFamily': widget.style?.fontFamily,
        'fontSize': '${widget.style?.fontSize ?? kCardFieldDefaultFontSize}px',
        'color': colorToCssString(widget.style?.textColor ?? Colors.black),
        if (widget.style?.fontWeight != null) 'fontWeight': widget.style?.fontWeight,
        if (widget.style?.placeholderColor != null)
          '::placeholder': {
            'color': colorToCssString(widget.style?.placeholderColor ?? Colors.black),
          },
      },
    });
  }

  @override
  void didUpdateWidget(covariant WebCardField oldWidget) {
    if (widget.controller != oldWidget.controller) {
      assert(!controller.hasCardField, 'CardEditController is already attached to a CardView');
      detachController(oldWidget.controller);
      attachController(oldWidget.controller);
    }
    if (widget.enablePostalCode != oldWidget.enablePostalCode ||
        widget.placeholder != oldWidget.placeholder ||
        widget.style != oldWidget.style) {
      element?.update(createOptions());
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    detachController(controller);
    element?.unmount();
    super.dispose();
  }

  @override
  void blur() {
    element?.blur();
  }

  @override
  void clear() {
    element?.clear();
  }

  @override
  void focus() {
    element?.focus();
  }

  @override
  void dangerouslyUpdateCardDetails(CardFieldInputDetails details) {
    throw UnimplementedError();
  }
}
