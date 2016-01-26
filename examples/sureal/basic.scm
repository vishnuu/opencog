; Copyright (C) 2016 OpenCog Foundation
;
; A simple demo for Surface Realization (SuReal)
;
; For more details about SuReal, please check:
; https://github.com/opencog/opencog/blob/master/opencog/nlp/sureal/README.md
; http://wiki.opencog.org/w/Surface_Realization_%28SuReal%29
;
; Prior to running this, the RelEx parse server needs to be set up,
; so that the `nlp-parse` call succeeds. The directory containing the
; chatbot has detailed instructions on how to do this.

; Load the needed modules!
(use-modules (opencog)
             (opencog nlp)
             (opencog nlp sureal)
             (opencog nlp chatbot)) ; the chatbot defines nlp-parse

; SuReal depends on the contents of the AtomSpace, specifically the existing
; sentences, i.e. the sentences/utterances that were parsed via the `nlp-parse`
; scheme function. Let's start by parsing one sentence into AtomSpace:
(nlp-parse "Roy runs.")

; After successfully parsing the above sentence, SuReal will now be able to
; generate new sentences that are syntactically identical to the above one,
; for example, "she drinks."
; But before calling SuReal, let's do one more thing:
(WordNode "she")
(WordNode "drinks")

; The reason of inserting two WordNodes in advance is that SuReal needs to distinguish
; "word" atoms (i.e. nodes that were and/or will be words in actual sentences)
; from other nodes, one way of doing so is to see if the PredicateNode "drinks"
; is linked with its corresponding WordNode "drinks", similarly for ConceptNode "she"
; to WordNode "she"
; NOTE: The above step is not necessary if we already have some parsed sentences
;       that contains both of the words "she" and "drinks", in that case those
;       WordNodes would have been generated already, so no need to insert them
;       explicitly
;
; Finally, let's generate a new sentence by running SuReal
; Expected result: "she drinks ."
(sureal (SetLink (EvaluationLink (PredicateNode "drinks") (ListLink (ConceptNode "she")))))

; Let's parse a few more sentences into the AtomSpace
(nlp-parse "That lovely pig eats the apple.")
(nlp-parse "The cat he loves can fly.")
(nlp-parse "Jumpy the dog can slowly sign his own name in green paint.")

; And then try to generate a slightly more complex sentence
; Expected result: "that green cat loves the dog ."
(sureal (SetLink (EvaluationLink (PredicateNode "loves") (ListLink (ConceptNode "cat") (ConceptNode "dog")))
                 (InheritanceLink (ConceptNode "cat") (ConceptNode "green"))))

; NOTE: The word "that" was not in the input but was included in the output,
;       it's because the only syntactically matching sentence available in the
;       AtomSpace is "That lovely pig eats the apple.", with the word "that"
;       being the starting word of the sentence. Currently when SuReal finds a
;       match, it substitutes the words from that sentence by those syntactically
;       matching words from the input, while leaving the leftovers untouched.
;       This can be confusing sometimes, future version of SuReal may handle
;       this differently.
;
; Additionally, if there are two (or more) matching sentences, SuReal will return
; the best/good enough one. For example if we also have:
(nlp-parse "Tom reads quickly.")

; And then run:
(sureal (SetLink (EvaluationLink (PredicateNode "eats") (ListLink (ConceptNode "he")))))

; Expected result is "he eats ." instead of "he eats quickly ." though both
; of the sentences "Roy runs." and "Tom reads quickly." are matched.
