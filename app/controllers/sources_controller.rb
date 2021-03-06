class SourcesController < ApplicationController

  before_action :find_source, only: [:show, :edit, :update, :destroy, :transactions]

  def index
    @sources = Source.order(:name)
  end

  def show

  end

  def new
    @source = Source.new
  end

  def edit

  end

  def create
    @source = Source.new(source_params)
    @source.save ? redirect_to(@source) : render(:new)
  end

  def create_many
    results = params[:sources].map do |source|
      s = Source.create(source_hash(source))
      s.errors.empty? ? "#{s.name} created successfully." : s.custom_error_messages
    end

    redirect_to sources_path, notice: results.join(' ')
  end

  def update
    @source.update(source_params) ? redirect_to(@source) : render(:edit)
  end

  def update_many
    redirect_to sources_path and return if params[:sources].nil?

    results = params[:sources].map do |k,v|
      source = Source.find(k.to_i)
      source.update(source_hash(v))
      source.errors.empty? ? "Source #{source.id} successfully updated." : "Source #{source.id} did not update. #{source.custom_error_messages.join(', ')}"
    end

    redirect_to sources_path, flash: { notices: results }
  end

  def clear
    Source.update_all(total: 0, popularity: 0)
    redirect_to sources_path, notice: 'Sources cleared.'
  end

  def refresh
    Source.all.each do |source|
      source.update(total: source.transactions.sum(:amount), popularity: source.transactions.count)
    end
    redirect_to sources_path, notice: 'Sources refreshed.'
  end

  def bubbles
    @attribute = params[:graph_by] == 'popularity' ? 'popularity' : 'total'

    sources = Source.select("name, #{@attribute}").order(@attribute)


    # here I am looking for the max total within 1 standard deviation
    average = sources.average(@attribute)

    totals = sources.pluck(@attribute)

    squared_difference = totals.map { |num| (num - average) * (num - average)}

    variance = squared_difference.sum / squared_difference.length

    standard_deviation = Math.sqrt(variance)

    @max_standard = (average + standard_deviation).to_f


    @max = sources.maximum(@attribute)
    @min = sources.minimum(@attribute)


    @data = Source.graph_points_by(@attribute, sources)
  end

  # maybe this belongs in transaction controller
  def guess
    unknown = Transaction.where(source: nil)

    splitter = Parser.parser.split_transformation.regex

    @guesses = unknown.map { |u|
      u.description.split(/#{splitter}/).first
    }.uniq.sort_by(&:downcase)

    respond_to do |format|
      format.js
    end
  end

  def transactions
    @transactions = @source.transactions
    render 'transactions/transactions'
  end

  def destroy
    if @source.destroy
      redirect_to sources_path, notice: 'Source successfully destroyed.'
    else
      redirect_to sources_path, flash: { error: 'Failed to destroy source.' }
    end
  end

  private

  def find_source
    begin
      @source = Source.find(params[:id].to_i)
    rescue
      # what
    end
  end

  def source_params
    source_hash(params.require(:source))
  end

  def source_hash(hash)
    hash.permit(:name, :regex, :purpose_id)
  end
end
