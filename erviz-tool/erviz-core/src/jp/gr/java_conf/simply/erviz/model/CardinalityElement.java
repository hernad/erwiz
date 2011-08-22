package jp.gr.java_conf.simply.erviz.model;

/**
 * This enum class represents one side of cardinality between two entities.
 * For example, one or many of one-to-many cardinality.
 * 
 * @author kono
 * @version 1.0
 * @see jp.gr.java_conf.simply.erviz.model.CardinalityWithOptionality
 */
public enum CardinalityElement {
	
	/** Not specified */
	NONE,
	
	/** One */
	ONE,
	
	/** Many */
	MANY;
	
}